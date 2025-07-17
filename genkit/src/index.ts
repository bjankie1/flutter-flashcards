/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { genkit } from "genkit";
import { googleAI } from "@genkit-ai/googleai";
import axios from "axios";
import { z } from "@genkit-ai/core";
import { onRequest } from "firebase-functions/v2/https";

const ai = genkit({
  plugins: [
    googleAI(),
  ],
});

export {
  cardAnswer,
  deckCategory,
  generateFlashCardsFromText,
  generateFlashCardsFromBinary,
  translateToEnglish,
} from "./genkit-cardSuggestions.js";

export const getGoogleDocContent = ai.defineFlow(
  {
    name: "getGoogleDocContent",
    inputSchema: z.string(),
    outputSchema: z.string(),
  },
  async (url: string) => {
    const extractDocId = (url: string): string | null => {
      const regex = /\/document\/d\/([a-zA-Z0-9_-]+)/;
      const match = regex.exec(url);
      return match ? match[1] : null;
    };

    const docId = extractDocId(url);
    if (!docId) {
      throw new Error("Invalid Google Doc URL");
    }

    const exportUrl = `https://docs.google.com/document/d/${docId}/export?format=txt`;
    try {
      const response = await axios.get(exportUrl);
      if (typeof response.data !== 'string') {
        throw new Error('Expected document content to be a string');
      }
      return response.data;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      console.error(`Error fetching doc: ${errorMessage}`);
      throw new Error("Failed to load Google Doc");
    }
  }
);

export const helloWorld = onRequest((req: any, res: any) => {
  res.send("Hello from Firebase!");
});