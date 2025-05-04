// Import the Genkit core libraries and plugins.
import { genkit, z } from "genkit";
import { gemini20FlashExp, googleAI } from "@genkit-ai/googleai";
// Import the Genkit Firebase Functions integration
import { onCallGenkit } from "firebase-functions/https";

// Import Firebase Functions related modules
import { defineSecret } from "firebase-functions/params";
import { setGlobalOptions } from "firebase-functions/v2";

// Define secrets
const googleAIapiKey = defineSecret("GOOGLE_GENAI_API_KEY");

// Set global options for Firebase Functions (v2)
setGlobalOptions({ region: "europe-central2" });

// Initialize Genkit with the Google AI plugin
const ai = genkit({
  plugins: [
    // Load the Google AI plugin. It will use the GOOGLE_GENAI_API_KEY environment variable.
    googleAI(),
  ],
});

// Define Zod schemas for input and output validation
const DeckInfoSchema = z.object({
  deckName: z.string(),
  deckDescription: z.string().optional(),
});


const CardDetailsSchema = z.object({
  deckName: z.string(),
  deckDescription: z.string().optional(),
  cardQuestion: z.string(),
  category: z.enum(["language", "history", "science", "other"]).optional(),
});

const AnswerAndExplanation = z.object({
  answer: z.string(),
  explanation: z.string(),
});

// Define an enum for categories
enum Category {
  language,
  history,
  science,
  other,
}

/**
 * Converts a string category name to the Category enum.
 * Comparison is case-insensitive and ignores non-letter characters.
 * @param {string} value - Category name string.
 * @return {Category} The corresponding enum value, defaults to Category.other.
 */
function stringToCategory(value: string): Category {
  switch (value.replace(/[^a-zA-Z]/g, "").toLowerCase()) {
  case "language":
    return Category.language;
  case "history":
    return Category.history;
  case "science":
    return Category.science;
  default:
    return Category.other;
  }
}

/**
 * Generates a system prompt based on the flashcard category.
 * @param {Category} category - The category of the deck.
 * @return {string} The generated system prompt.
 */
function systemPrompt(category: Category): string {
  switch (category) {
  case Category.language:
    return `You are a flashcard creation assistant. Given a question or term related to languages,
               provide a concise and informative answer suitable for a flashcard.
               Answers should be accurate and easy to understand for studying.
               There are two languages involved in such flashcards. One is the native language of
               the person learning the cards and the second is the language being learnt. It can
               be assumed that the language of deck name and deck description is the native
               language of the student. The answer should should be provided in language different
               than the language of the question.
               When providing an optional explanation you can use markdown
               formatting. Explanation should be brief - it may include dictionary definition
               of a word. In case of sentences no explanation is required unless there are some
               nuances to explain.`;
  case Category.history:
    return `You are a flashcard creation assistant. Given a question or term related to history,
               provide a concise and informative answer suitable for a flashcard.
               Answers should be accurate and easy to understand for studying.
               Both answer and explanation should be provided in the same language as question and
               deck description.
               Explanation can be slightly longer to provide more context about the answer so that
               the reader can find the rationale. Use markdown formatting in necessary to highlight
               important part of sequence or headers. In response provide answer and explanation.`;
  case Category.science:
    return `You are a flashcard creation assistant. Generate concise, accurate, and informative
       answers suitable for flashcards. Answers should be easy to understand for studying. Use
       Markdown to format both answer and explanation.
       Both answer and explanation should be provided in the same language as question and
       deck description.
       For answers involving mathematical, chemical, or physical concepts
       or calculations, express formulas using LaTeX inline math mode (e.g., $E=mc^2$). If a
       question requires calculations to arrive at the answer, include a clear, step-by-step
       explanation of the calculation process.`;
  default: // Category.other
    return `You are a flashcard creation assistant. Given a question or term,
               provide a concise and informative answer suitable for a flashcard.
               Both answer and explanation should be provided in the same language as question and
               deck description.
               Answers should be accurate and easy to understand for studying.
               When providing an optional explanation you can use markdown
               formatting.`;
  }
}

/**
 * Generates a user prompt based on the flashcard category and details.
 * @param {Category} category - Category of the deck.
 * @param {string} deckName - Name of the deck.
 * @param {string} deckDescription - Description of the deck.
 * @param {string} cardQuestion - Question for the flashcard.
 * @return {string} The generated user prompt.
 */
function userPrompt(
  category: Category,
  deckName: string,
  deckDescription: string,
  cardQuestion: string
): string {
  if (category == Category.language) {
    return `Provide translation of the question and phonetic transcription
    in the answer case of translating short texts
    - up to 3 words.

    Question: ${cardQuestion}
        deck name: ${deckName}
        deck description: ${deckDescription}`;
  } else {
    return `Question: ${cardQuestion}
        deck name: ${deckName}
        deck description: ${deckDescription}`;
  }
}

// Genkit flow to determine the category of a flashcard deck
const cardTypeFlow = ai.defineFlow(
  {
    name: "cardTypeFlow",
    inputSchema: DeckInfoSchema,
    outputSchema: z.string(), // Expecting a string representing the category
  },
  async (subject) => {
    // Call the AI model to classify the deck
    const result = await ai.generate({
      model: gemini20FlashExp, // Specify the model
      system: `Classify flashcard based on provided information such as deckName,
deckDescription and the question. Pick one of provided categories: language, history, science, other.
NEVER add additional characters to the output such as extra quotes.
Do not respond with null, always pick the best fitting category, if you are unsure select 'other'.`, // System instructions
      prompt: `Given the following information about a deck and a question, classify the question into one of the provided categories:
                Deck Name: ${subject.deckName}
                Deck Description: ${subject.deckDescription}`, // User prompt with deck info
      config: {
        temperature: 0.0, // Low temperature for deterministic classification
      },
    });

    // Check if the result text is valid
    if (result.text == null) {
      throw new Error("AI model did not return a category");
    }
    const responseText = result.text;
    console.log("Direct API Response for category:", responseText);
    // Return the classified category string
    return responseText.trim(); // Trim whitespace
  }
);

// Genkit flow to suggest an answer and explanation for a flashcard
const cardAnswerSuggestionFlow = ai.defineFlow(
  {
    name: "cardAnswerSuggestionFlow",
    inputSchema: CardDetailsSchema,
    outputSchema: AnswerAndExplanation, // Expecting an object with answer and explanation
  },
  async (subject) => {
    // Determine the category: use provided category or classify using cardTypeFlow
    const categoryString = subject.category ?
      subject.category :
      await cardTypeFlow(subject); // Call the classification flow if category not provided

    // Convert the category string to the enum type
    const category = stringToCategory(categoryString);

    // Generate the answer and explanation using the AI model
    const { output } = await ai.generate({
      model: gemini20FlashExp, // Specify the model
      system: systemPrompt(category), // Get system prompt based on category
      output: {
        schema: AnswerAndExplanation, // Define the expected output schema
      },
      prompt: userPrompt( // Get user prompt based on category and card details
        category,
        subject.deckName,
        subject.deckDescription ?? '', // Use empty string if description is null/undefined
        subject.cardQuestion
      ),
      config: {
        temperature: 0.4, // Moderate temperature for creative but relevant answers
      },
    });

    // Validate the output
    if (output == null) {
      throw new Error("AI response doesn't satisfy the required schema");
    }
    // Return the generated answer and explanation
    return output;
  }
);

// Import prompt
export const generateFlashCardsFromTextPrompt = ai.prompt('generateFlashCardsFromText');

// Define Input Schema (using Zod, matching the prompt's input schema)
const FlashcardRequestSchema = z.object({
  frontLanguage: z.string(),
  backLanguage: z.string(),
  text: z.string(),
});

// Define Output Schema explicitly
// Even though it's in the prompt, defining it here provides compile-time safety.
const FlashcardResponseSchema = z.object({
    cards: z.array(z.object({
        front: z.string(),
        back: z.string()
    }))
});

export const flashcardGeneratorFlow = ai.defineFlow(
  {
    name: 'flashcardGeneratorFlow', // Name for tracing/debugging
    inputSchema: FlashcardRequestSchema,
    outputSchema: FlashcardResponseSchema, // Use the explicitly defined Zod schema
  },
  async (input) => { // Input is validated against FlashcardRequestSchema
    const rendered = await generateFlashCardsFromTextPrompt.render({
        input: input, // Pass the flow's input to the prompt's render method
    });

    const { output } = await ai.generate({
      messages: rendered.messages, // Pass the fully rendered messages array
      model: gemini20FlashExp,     // Specify the model
      config: {
        temperature: 0.45,      // Your config overrides
      },
      output: {                 // Output constraints
          format: 'json',
          schema: FlashcardResponseSchema
      }
    });

    // Validate the output
    if (output == null) {
      throw new Error("AI response doesn't satisfy the required schema");
    }
    // Return the generated answer and explanation
    return output;
  }
);

// Firebase Cloud Function endpoint to get card answer suggestions
export const cardAnswer = onCallGenkit(
  {
    // Define the authentication policy
    authPolicy: (auth, ) => auth?.token?.['email_verified'] || false,
    cors: "*", // Configure CORS policy (use cautiously in production)
    secrets: [googleAIapiKey], // Specify secrets needed by the function
  },
  cardAnswerSuggestionFlow
);

// Firebase Cloud Function endpoint to get the deck category
export const deckCategory = onCallGenkit({
      authPolicy: (auth, ) => auth?.token?.['email_verified'] || false,
      secrets: [googleAIapiKey],
      cors: "*",
    },
    cardTypeFlow
);

export const generateFlashCardsFromText = onCallGenkit({
      authPolicy: (auth, ) => auth?.token?.['email_verified'] || false,
      secrets: [googleAIapiKey],
      cors: "*",
    },
    flashcardGeneratorFlow
);