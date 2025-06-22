/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { configureGenkit } from '@genkit-ai/core';
import { firebase } from '@genkit-ai/firebase';
import { googleAI } from '@genkit-ai/googleai';
import { defineFlow, startFlows } from '@genkit-ai/flow';
import * as z from 'zod';
import { dotprompt } from '@genkit-ai/dotprompt';
import axios from 'axios';

configureGenkit({
  plugins: [
    firebase(),
    googleAI(),
    dotprompt({
      promptDir: './prompts',
    }),
  ],
  logLevel: 'debug',
  enableTracingAndMetrics: true,
});

export {
  cardAnswer,
  deckCategory,
  generateFlashCardsFromText,
} from './genkit-cardSuggestions';

export { getGoogleDocContent } from "./google-doc-importer";

export const getGoogleDocContent = defineFlow(
  {
    name: 'getGoogleDocContent',
    inputSchema: z.string(),
    outputSchema: z.string(),
  },
  async (url) => {
    const extractDocId = (url: string): string | null => {
      const regex = /\\/document\\/d\\/([a-zA-Z0-9_-]+)/;
      const match = regex.exec(url);
      return match ? match[1] : null;
    };

    const docId = extractDocId(url);
    if (!docId) {
      throw new Error('Invalid Google Doc URL');
    }

    const exportUrl = `https://docs.google.com/document/d/${docId}/export?format=txt`;
    try {
      const response = await axios.get(exportUrl);
      return response.data;
    } catch (e: any) {
      console.error(`Error fetching doc: ${e.message}`);
      throw new Error('Failed to load Google Doc');
    }
  }
);

startFlows();