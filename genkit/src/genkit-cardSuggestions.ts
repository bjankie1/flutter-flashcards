// Import the Genkit core libraries and plugins.
import { genkit, z } from "genkit";
import { gemini20FlashExp, googleAI } from "@genkit-ai/googleai";

// From the Firebase plugin, import the functions needed to deploy flows using
// Cloud Functions.
import { firebaseAuth } from "@genkit-ai/firebase/auth";
import { onFlow } from "@genkit-ai/firebase/functions";

import { defineSecret } from "firebase-functions/params";
const googleAIapiKey = defineSecret("GOOGLE_GENAI_API_KEY");

import { setGlobalOptions } from "firebase-functions/v2";

setGlobalOptions({ region: "europe-central2" });

const ai = genkit({
  plugins: [
    // Load the Google AI plugin. You can optionally specify your API key
    // by passing in a config object; if you don't, the Google AI plugin uses
    // the value from the GOOGLE_GENAI_API_KEY environment variable, which is
    // the recommended practice.
    googleAI(),
  ],
});

const DeckInfoSchema = z.object({
  deckName: z.string(),
  deckDescription: z.string(),
});


const CardDetailsSchema = z.object({
  deckName: z.string(),
  deckDescription: z.string(),
  cardQuestion: z.string(),
  category: z.enum(["language", "history", "science", "other"]).optional(),
});

const AnswerAndExplanation = z.object({
  answer: z.string(),
  explanation: z.string(),
});

enum Category {
  language,
  history,
  science,
  other,
}

/**
 * String value should be compared case insensitive and all non-letter characters
 * should be removed first.
 * @param {string} value - Category name
 * @return {Category} the enum value, default Category.other
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
 * Generate system prompt for given category of deck.
 *
 * @param {Category} category Category Category of deck
 * @return {string} Generated system prompt
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
       Markdown for formatting. 
       Both answer and explanation should be provided in the same language as question and
       deck description.
       For answers involving mathematical, chemical, or physical concepts
       or calculations, express formulas using LaTeX inline math mode (e.g., $E=mc^2$). If a 
       question requires calculations to arrive at the answer, include a clear, step-by-step
       explanation of the calculation process.`;
  default:
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
 * Generate user prompt for given category of deck.
 *
 * @param {Category} category Category of deck
 * @param {string} deckName Name of deck
 * @param {string} deckDescription Description of deck
 * @param {string} cardQuestion Question for flashcard
 *
 * @return {string}
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

const cardTypeFlow = ai.defineFlow(
  {
    name: "cardTypeFlow",
    inputSchema: DeckInfoSchema,
    outputSchema: z.string(),
  },
  async (subject) => {
    const result = await ai.generate({
      model: gemini20FlashExp,
      system: `Classify flashcard based on provided information such as deckName,
deckDescription and the question. Pick one of provided categories: language, history, science, other.
NEVER add additional characters to the output such as extra quotes.
Do not respond with null, always pick the best fitting category, if you are unsure select 'other'.`,
      prompt: `Given the following information about a deck and a question, classify the question into one of the provided categories:
                Deck Name: ${subject.deckName}
                Deck Description: ${subject.deckDescription}`,
      // output: {
      //   schema: z.object({ category: z.string() }),
      // },
      config: {
        temperature: 0.0,
      },
    });
    if (result.text == null) {
      throw new Error("No result");
    }
    const responseText = result.text;
    console.log("Direct API Response:", responseText);
    return responseText;
  }
);

const cardAnswerSuggestionFlow = ai.defineFlow(
  {
    name: "cardAnswerSuggestionFlow",
    inputSchema: CardDetailsSchema,
    outputSchema: AnswerAndExplanation,
  },
  async (subject) => {
    const categoryString = subject.category ?
      subject.category :
      await cardTypeFlow(subject);
    const category = stringToCategory(categoryString);
    const { output } = await ai.generate({
      model: gemini20FlashExp,
      system: systemPrompt(category),
      output: {
        schema: AnswerAndExplanation,
      },
      prompt: userPrompt(
        category,
        subject.deckName,
        subject.deckDescription,
        subject.cardQuestion
      ),
      config: {
        temperature: 0.4,
      },
    });
    if (output == null) {
      throw new Error("Response doesn't satisfy the schema");
    }
    return output;
  }
);

export const cardAnswer = onFlow(
  ai,
  {
    name: "cardAnswer",
    inputSchema: CardDetailsSchema,
    outputSchema: AnswerAndExplanation,
    authPolicy: firebaseAuth((user) => {
      if (!user.email_verified) {
        throw new Error("Verified email required to run flow");
      }
    }),
    httpsOptions: {
      secrets: [googleAIapiKey],
      cors: "*",
    },
  },
  async (subject) => {
    return await cardAnswerSuggestionFlow(subject);
  }
);

export const deckCategory = onFlow(
  ai,
  {
    name: "deckCategory",
    inputSchema: DeckInfoSchema,
    outputSchema: z.string(),
    authPolicy: firebaseAuth((user) => {
      if (!user.email_verified) {
        // throw new Error("Verified email required to run flow");
      }
    }),
    httpsOptions: {
      secrets: [googleAIapiKey],
      cors: "*",
    },
  },
  async (subject) => {
    return await cardTypeFlow(subject);
  }
);

