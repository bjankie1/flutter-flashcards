// Import the Genkit core libraries and plugins.
import { genkit, z } from "genkit";
import { gemini20FlashExp, googleAI } from "@genkit-ai/googleai";
// Import the Genkit Firebase Functions integration
import { onCallGenkit } from "firebase-functions/https";

// Initialize Genkit with the Google AI plugin
const ai = genkit({
  plugins: [
    // Load the Google AI plugin. It will use the GOOGLE_GENAI_API_KEY environment variable.
    googleAI(),
  ],
});

// Define Zod schemas for input and output validation
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
  biology,
  geography,
  math,
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
  case "biology":
    return Category.biology;
  case "geography":
    return Category.geography;
  case "math":
    return Category.math;
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
  case Category.biology:
    return `You are a flashcard creation assistant. Given a question or term related to biology,
               provide a concise and informative answer suitable for a flashcard.
               Answers should be accurate and easy to understand for studying.
               Both answer and explanation should be provided in the same language as question and
               deck description.
               For biological concepts, include relevant scientific terminology and explanations
               that help with understanding. Use markdown formatting when necessary to highlight
               important terms or concepts.`;
  case Category.geography:
    return `You are a flashcard creation assistant. Given a question or term related to geography,
               provide a concise and informative answer suitable for a flashcard.
               Answers should be accurate and easy to understand for studying.
               Both answer and explanation should be provided in the same language as question and
               deck description.
               For geographical concepts, include relevant location details, climate information,
               or cultural context as appropriate. Use markdown formatting when necessary to
               highlight important geographical features or terms.`;
  case Category.math:
    return `You are a flashcard creation assistant. Given a question or term related to mathematics,
               provide a concise and informative answer suitable for a flashcard.
               Answers should be accurate and easy to understand for studying.
               Both answer and explanation should be provided in the same language as question and
               deck description.
               For mathematical concepts, express formulas using LaTeX inline math mode (e.g., $E=mc^2$).
               If a question requires calculations, include a clear, step-by-step explanation
               of the calculation process. Use markdown formatting to structure mathematical
               expressions and explanations clearly.`;
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
    inputSchema: z.object({
      deckName: z.string(),
      subject: z.string(),
      description: z.string(),
    }),
    outputSchema: z.object({
      category: z.string(),
      confidence: z.number(),
    }),
  },
  async (subject: any) => {
    // Call the AI model to classify the deck
    const result = await ai.generate({
      model: gemini20FlashExp,
      system: `Classify flashcard based on provided information such as deckName,\ndeckDescription and the question. Pick one of provided categories: language, history, science, biology, geography, math, other.\nNEVER add additional characters to the output such as extra quotes.\nDo not respond with null, always pick the best fitting category, if you are unsure select 'other'.`,
      prompt: `Given the following information about a deck and a question, classify the question into one of the provided categories:\n                Deck Name: ${subject.deckName}\n                Deck Description: ${subject.deckDescription}`,
      config: {
        temperature: 0.0,
      },
    });
    if (!result.text) throw new Error("AI model did not return a category");
    return { category: result.text.trim(), confidence: 1 };
  }
);

// Genkit flow to suggest an answer and explanation for a flashcard
const cardAnswerSuggestionFlow = ai.defineFlow(
  {
    name: "cardAnswerSuggestionFlow",
    inputSchema: CardDetailsSchema,
    outputSchema: AnswerAndExplanation, // Expecting an object with answer and explanation
  },
  async (subject: any) => {
    // Determine the category: use provided category or classify using cardTypeFlow
    const categoryString = subject.category ?
      subject.category :
      await cardTypeFlow({
        deckName: subject.deckName,
        subject: subject.deckName,
        description: subject.deckDescription || "",
      });

    const category = stringToCategory(categoryString.category || categoryString);

    // Generate the answer and explanation using the AI model
    const { output } = await ai.generate({
      model: gemini20FlashExp, // Specify the model
      system: systemPrompt(category), // Get system prompt based on category
      prompt: userPrompt(category, subject.deckName, subject.deckDescription || "", subject.cardQuestion), // Get user prompt
      config: {
        temperature: 0.7, // Moderate temperature for creative but consistent responses
      },
    });

    // Parse the response to extract answer and explanation
    const responseText = output.text || "";
    const lines = responseText.split('\n').filter((line: string) => line.trim() !== '');
    
    // Simple parsing: first line is answer, rest is explanation
    const answer = lines[0] || "";
    const explanation = lines.slice(1).join('\n') || "";

    return {
      answer: answer.trim(),
      explanation: explanation.trim(),
    };
  }
);

// Import prompt
export const generateFlashCardsFromTextPrompt = ai.prompt('generateFlashCardsFromText');

// Define Input Schema (using Zod, matching the prompt's input schema)
const GenerateFlashCardsInputSchema = z.object({
  text: z.string().describe("The text content to generate flashcards from"),
  numberOfCards: z.number().optional().describe("Number of flashcards to generate (default: 5)"),
  difficulty: z.enum(["easy", "medium", "hard"]).optional().describe("Difficulty level of the flashcards"),
});

// Define Output Schema (using Zod, matching the prompt's output schema)
const GenerateFlashCardsOutputSchema = z.object({
  flashcards: z.array(z.object({
    question: z.string().describe("The question for the flashcard"),
    answer: z.string().describe("The answer for the flashcard"),
    explanation: z.string().optional().describe("Optional explanation for the answer"),
  })).describe("Array of generated flashcards"),
});

export const flashcardGeneratorFlow = ai.defineFlow(
  {
    name: 'flashcardGeneratorFlow', // Name for tracing/debugging
    inputSchema: GenerateFlashCardsInputSchema,
    outputSchema: GenerateFlashCardsOutputSchema,
  },
  async (input) => {
    // Render the prompt with the input data
    const rendered = await generateFlashCardsFromTextPrompt.render({
      text: input.text,
      numberOfCards: input.numberOfCards || 5,
      difficulty: input.difficulty || "medium",
    });

    // Generate the flashcards using the AI model
    const { output } = await ai.generate({
      messages: rendered.messages, // Pass the fully rendered messages array
      model: gemini20FlashExp,     // Specify the model
      config: {
        temperature: 0.7,          // Moderate temperature for creative but consistent responses
      },
    });

    // Parse the response to extract flashcards
    const responseText = output.text || "";
    
    // Simple parsing: look for question/answer pairs
    const flashcards = [];
    const lines = responseText.split('\n').filter((line: string) => line.trim() !== '');
    
    for (let i = 0; i < lines.length; i += 2) {
      if (i + 1 < lines.length) {
        flashcards.push({
          question: lines[i].replace(/^Q[:\s]*/, '').trim(),
          answer: lines[i + 1].replace(/^A[:\s]*/, '').trim(),
        });
      }
    }

    return {
      flashcards: flashcards.slice(0, input.numberOfCards || 5),
    };
  }
);

// Export the functions
export const cardAnswer = onCallGenkit(cardAnswerSuggestionFlow);
export const deckCategory = onCallGenkit(cardTypeFlow);
export const generateFlashCardsFromText = onCallGenkit(flashcardGeneratorFlow);