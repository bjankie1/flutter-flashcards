// Import the Genkit core libraries and plugins.
import { genkit, z } from "genkit";
import { googleAI } from "@genkit-ai/googleai";
// Import the Genkit Firebase Functions integration
import { onCallGenkit } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
const googleAIapiKey = defineSecret("GEMINI_API_KEY");

// Initialize Genkit with the Google AI plugin
const ai = genkit({
  plugins: [
    // Load the Google AI plugin with Firebase Functions secret for production
    googleAI(),
  ],
  model: googleAI.model('gemini-2.5-flash', {
    temperature: 0.8
  }),
});

// Genkit flow to translate text to English
const translateToEnglishFlow = ai.defineFlow(
  {
    name: "translateToEnglishFlow",
    inputSchema: z.object({
      text: z.string(),
    }),
    outputSchema: z.object({
      translatedText: z.string(),
    }),
  },
  async (subject: any) => {
    try {
      console.log('Starting translateToEnglishFlow with input:', JSON.stringify(subject, null, 2));
      
      // Call the AI model to translate the text
      const result = await ai.generate({
        system: `You are a translation assistant. Translate the given text to English.
                 Provide only the translated text without any additional explanations or formatting.
                 If the text is already in English, return it unchanged.
                 Keep the translation concise and natural.`,
        prompt: `Translate the following text to English:\n\n${subject.text}`,
        config: {
          temperature: 0.1, // Low temperature for consistent translations
        },
      });
      
      if (!result.text) {
        throw new Error("AI model did not return a translation");
      }
      
      const translatedText = result.text.trim();
      console.log('Translation completed successfully:', { translatedText });
      return { translatedText };
      
    } catch (error) {
      console.error('Error in translateToEnglishFlow:', error);
      console.error('Error stack:', error instanceof Error ? error.stack : 'No stack trace');
      console.error('Input that caused error:', JSON.stringify(subject, null, 2));
      
      // Return the original text as fallback
      return {
        translatedText: subject.text,
      };
    }
  }
);

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
    try {
      console.log('Starting cardTypeFlow with input:', JSON.stringify(subject, null, 2));
      
      // Call the AI model to classify the deck
      const result = await ai.generate({
        system: `Classify flashcard based on provided information such as deckName,\ndeckDescription and the question. Pick one of provided categories: language, history, science, biology, geography, math, other.\nNEVER add additional characters to the output such as extra quotes.\nDo not respond with null, always pick the best fitting category, if you are unsure select 'other'.`,
        prompt: `Given the following information about a deck and a question, classify the question into one of the provided categories:\n                Deck Name: ${subject.deckName}\n                Deck Description: ${subject.deckDescription}`,
        config: {
          temperature: 0.0,
        },
      });
      
      if (!result.text) {
        throw new Error("AI model did not return a category");
      }
      
      const category = result.text.trim();
      console.log('Flow completed successfully:', { category, confidence: 1 });
      return { category, confidence: 1 };
      
    } catch (error) {
      console.error('Error in cardTypeFlow:', error);
      console.error('Error stack:', error instanceof Error ? error.stack : 'No stack trace');
      console.error('Input that caused error:', JSON.stringify(subject, null, 2));
      
      // Return a fallback response instead of throwing
      return {
        category: "other",
        confidence: 0,
      };
    }
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

// Define Input Schema for binary data processing
const GenerateFlashCardsFromBinaryInputSchema = z.object({
  binaryData: z.string().describe("Base64 encoded binary data"),
  fileType: z.enum(["pdf", "image"]).describe("Type of file (pdf or image)"),
  fileName: z.string().describe("Name of the uploaded file"),
  frontLanguage: z.string().optional().describe("Language for the front of cards"),
  backLanguage: z.string().optional().describe("Language for the back of cards"),
});

// Define Output Schema for binary data processing
const GenerateFlashCardsFromBinaryOutputSchema = z.object({
  cards: z.array(z.object({
    front: z.string().describe("The question for the flashcard"),
    back: z.string().describe("The answer for the flashcard"),
  })).describe("Array of generated flashcards"),
});

export const flashcardGeneratorFromBinaryFlow = ai.defineFlow(
  {
    name: 'flashcardGeneratorFromBinaryFlow',
    inputSchema: GenerateFlashCardsFromBinaryInputSchema,
    outputSchema: GenerateFlashCardsFromBinaryOutputSchema,
  },
  async (input) => {
    // Process binary data based on file type
    let content = "";

    if (input.fileType === "pdf") {
      // For PDFs, we would use Firebase AI to extract text
      // For now, we'll simulate content extraction
      content = `This is simulated content extracted from the PDF file "${input.fileName}".
      
      The PDF appears to contain educational material that can be used to generate flashcards.
      Key topics include:
      - Important concepts and definitions
      - Historical events and dates
      - Scientific principles and formulas
      - Language learning vocabulary
      
      Based on this content, we can create flashcards covering these topics.`;
    } else if (input.fileType === "image") {
      // For images, we would use Firebase AI to extract text or describe the image
      // For now, we'll simulate image analysis
      content = `This is simulated content extracted from the image file "${input.fileName}".
      
      The image appears to contain visual information that can be used for learning.
      Possible content includes:
      - Diagrams and charts
      - Text or handwritten notes
      - Educational illustrations
      - Mathematical equations or formulas
      
      Based on this visual content, we can create flashcards covering these topics.`;
    }

    // Generate flashcards using the extracted content
    const { output } = await ai.generate({
      system: `You are a helpful AI assistant that generates flashcards from content.
               Generate 5 flashcards with questions and answers based on the provided content.
               Each flashcard should have a clear question and concise answer.
               Format your response as:
               Q: [Question]
               A: [Answer]
               Q: [Question]
               A: [Answer]
               ...`,
      prompt: `Generate flashcards from the following content:\n\n${content}`,
      config: {
        temperature: 0.7,
      },
    });

    // Parse the response to extract flashcards
    const responseText = output.text || "";
    const lines = responseText.split('\n').filter((line: string) => line.trim() !== '');

    const cards = [];
    for (let i = 0; i < lines.length; i += 2) {
      if (i + 1 < lines.length) {
        const question = lines[i].replace(/^Q[:\s]*/, '').trim();
        const answer = lines[i + 1].replace(/^A[:\s]*/, '').trim();

        if (question && answer) {
          cards.push({
            front: question,
            back: answer,
          });
        }
      }
    }

    // If we couldn't parse the response properly, generate some default cards
    if (cards.length === 0) {
      const defaultCards = [
        {
          front: `What type of file was uploaded?`,
          back: `${input.fileType.toUpperCase()} file`,
        },
        {
          front: `What is the name of the uploaded file?`,
          back: input.fileName,
        },
        {
          front: `What can be learned from this ${input.fileType} file?`,
          back: `Educational content and information that can be converted into flashcards`,
        },
      ];

      return {
        cards: defaultCards,
      };
    }

    return {
      cards: cards.slice(0, 5),
    };
  }
);

// Define Zod schemas for input and output validation
const CardDetailsSchema = z.object({
  deckName: z.string(),
  deckDescription: z.string().optional(),
  cardQuestion: z.string(),
  category: z.enum(["language", "history", "science", "other"]).optional(),
  frontCardDescription: z.string().optional(),
  backCardDescription: z.string().optional(),
  explanationDescription: z.string().optional(),
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
               language of the student. The answer should be provided in language different
               than the language of the question.
               When providing an optional explanation you can use markdown
               formatting. Explanation should be brief - it may include dictionary definition
               of a word. In case of sentences no explanation is required unless there are some
               nuances to explain.
               
               OUTPUT STRUCTURE:
               - "answer": The main response to the question (should follow back card description if provided)
               - "explanation": Additional context or details (should follow explanation description if provided)`;
    case Category.history:
      return `You are a flashcard creation assistant. Given a question or term related to history,
               provide a concise and informative answer suitable for a flashcard.
               Answers should be accurate and easy to understand for studying.
               Both answer and explanation should be provided in the same language as question and
               deck description.
               Explanation can be slightly longer to provide more context about the answer so that
               the reader can find the rationale. Use markdown formatting in necessary to highlight
               important part of sequence or headers.
               
               OUTPUT STRUCTURE:
               - "answer": The main response to the question (should follow back card description if provided)
               - "explanation": Additional context or details (should follow explanation description if provided)`;
    case Category.science:
      return `You are a flashcard creation assistant. Generate concise, accurate, and informative
       answers suitable for flashcards. Answers should be easy to understand for studying. Use
       Markdown to format both answer and explanation.
       Both answer and explanation should be provided in the same language as question and
       deck description.
       For answers involving mathematical, chemical, or physical concepts
       or calculations, express formulas using LaTeX inline math mode (e.g., $E=mc^2$). If a
       question requires calculations to arrive at the answer, include a clear, step-by-step
       explanation of the calculation process.
       
       OUTPUT STRUCTURE:
       - "answer": The main response to the question (should follow back card description if provided)
       - "explanation": Additional context or details (should follow explanation description if provided)`;
    case Category.biology:
      return `You are a flashcard creation assistant. Given a question or term related to biology,
               provide a concise and informative answer suitable for a flashcard.
               Answers should be accurate and easy to understand for studying.
               Both answer and explanation should be provided in the same language as question and
               deck description.
               For biological concepts, include relevant scientific terminology and explanations
               that help with understanding. Use markdown formatting when necessary to highlight
               important terms or concepts.
               
               OUTPUT STRUCTURE:
               - "answer": The main response to the question (should follow back card description if provided)
               - "explanation": Additional context or details (should follow explanation description if provided)`;
    case Category.geography:
      return `You are a flashcard creation assistant. Given a question or term related to geography,
               provide a concise and informative answer suitable for a flashcard.
               Answers should be accurate and easy to understand for studying.
               Both answer and explanation should be provided in the same language as question and
               deck description.
               For geographical concepts, include relevant location details, climate information,
               or cultural context as appropriate. Use markdown formatting when necessary to
               highlight important geographical features or terms.
               
               OUTPUT STRUCTURE:
               - "answer": The main response to the question (should follow back card description if provided)
               - "explanation": Additional context or details (should follow explanation description if provided)`;
    case Category.math:
      return `You are a flashcard creation assistant. Given a question or term related to mathematics,
               provide a concise and informative answer suitable for a flashcard.
               Answers should be accurate and easy to understand for studying.
               Both answer and explanation should be provided in the same language as question and
               deck description.
               For mathematical concepts, express formulas using LaTeX inline math mode (e.g., $E=mc^2$).
               If a question requires calculations, include a clear, step-by-step explanation
               of the calculation process. Use markdown formatting to structure mathematical
               expressions and explanations clearly.
               
               OUTPUT STRUCTURE:
               - "answer": The main response to the question (should follow back card description if provided)
               - "explanation": Additional context or details (should follow explanation description if provided)`;
    default: // Category.other
      return `You are a flashcard creation assistant. Given a question or term,
               provide a concise and informative answer suitable for a flashcard.
               Both answer and explanation should be provided in the same language as question and
               deck description.
               Answers should be accurate and easy to understand for studying.
               When providing an optional explanation you can use markdown
               formatting.
               
               OUTPUT STRUCTURE:
               - "answer": The main response to the question (should follow back card description if provided)
               - "explanation": Additional context or details (should follow explanation description if provided)`;
  }
}

/**
 * Generates a user prompt based on the flashcard category and details.
 * @param {Category} category - Category of the deck.
 * @param {string} deckName - Name of the deck.
 * @param {string} deckDescription - Description of the deck.
 * @param {string} cardQuestion - Question for the flashcard.
 * @param {string} frontCardDescription - Optional description for front of cards.
 * @param {string} backCardDescription - Optional description for back of cards.
 * @param {string} explanationDescription - Optional description for explanations.
 * @return {string} The generated user prompt.
 */
function userPrompt(
  category: Category,
  deckName: string,
  deckDescription: string,
  cardQuestion: string,
  frontCardDescription?: string,
  backCardDescription?: string,
  explanationDescription?: string
): string {
  let prompt = `Question: ${cardQuestion}
Deck name: ${deckName}
Deck description: ${deckDescription}`;

  if (frontCardDescription) {
    prompt += `\nFront card description: ${frontCardDescription}`;
  }
  if (backCardDescription) {
    prompt += `\nBack card description: ${backCardDescription}`;
  }
  if (explanationDescription) {
    prompt += `\nExplanation description: ${explanationDescription}`;
  }

  // Add clear instructions for using the deck descriptions
  prompt += `\n\nIMPORTANT INSTRUCTIONS:
- Generate an "answer" that follows the back card description (if provided)
- Generate an "explanation" that follows the explanation description (if provided)
- If no specific descriptions are provided, create appropriate answer and explanation based on the category and question
- The answer should be the main response to the question
- The explanation should provide additional context, details, or clarification`;

  return prompt;
}

// Genkit flow to suggest an answer and explanation for a flashcard
const cardAnswerSuggestionFlow = ai.defineFlow(
  {
    name: "cardAnswerSuggestionFlow",
    inputSchema: CardDetailsSchema,
    outputSchema: AnswerAndExplanation, // Expecting an object with answer and explanation
  },
  async (subject: any) => {
    try {
      console.log('Starting cardAnswerSuggestionFlow with input:', JSON.stringify(subject, null, 2));

      // Determine the category: use provided category or default to 'other'
      const categoryString = subject.category ?? 'other';

      const category = stringToCategory(categoryString);

      // Generate the answer and explanation using the AI model with structured output
      const { output } = await ai.generate({
        system: systemPrompt(category), // Get system prompt based on category
        prompt: userPrompt(
          category,
          subject.deckName,
          subject.deckDescription || "",
          subject.cardQuestion,
          subject.frontCardDescription,
          subject.backCardDescription,
          subject.explanationDescription
        ), // Get user prompt with deck descriptions
        config: {
          temperature: 0.7, // Moderate temperature for creative but consistent responses
        },
        output: {
          schema: AnswerAndExplanation,
        },
      });

      // Use the structured output directly
      if (!output) {
        throw new Error("AI model did not return a response");
      }

      const result = output as { answer: string; explanation: string };

      console.log('Flow completed successfully:', result);
      return result;

    } catch (error) {
      console.error('Error in cardAnswerSuggestionFlow:', error);
      console.error('Error stack:', error instanceof Error ? error.stack : 'No stack trace');
      console.error('Input that caused error:', JSON.stringify(subject, null, 2));

      // Return a fallback response instead of throwing
      return {
        answer: "Error generating answer. Please try again.",
        explanation: "The AI service encountered an error while processing your request.",
      };
    }
  }
);

// Export the functions
export const cardAnswer = onCallGenkit({
    secrets: [googleAIapiKey],
    region: "europe-central2"
  },
  cardAnswerSuggestionFlow);
export const deckCategory = onCallGenkit({
    secrets: [googleAIapiKey],
    region: "europe-central2"
  },
  cardTypeFlow);
export const generateFlashCardsFromText = onCallGenkit({
    secrets: [googleAIapiKey],
    region: "europe-central2"
  },
  flashcardGeneratorFlow);
export const generateFlashCardsFromBinary = onCallGenkit({
    secrets: [googleAIapiKey],
    region: "europe-central2"
  },
  flashcardGeneratorFromBinaryFlow);
export const translateToEnglish = onCallGenkit({
    secrets: [googleAIapiKey],
    region: "europe-central2"
  },
  translateToEnglishFlow);