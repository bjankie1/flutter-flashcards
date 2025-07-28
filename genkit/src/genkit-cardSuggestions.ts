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
  model: googleAI.model('gemini-2.5-flash-lite-preview-06-17', {
    temperature: 0.7
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
  frontCardDescription: z.string(),
  backCardDescription: z.string(),
  explanationDescription: z.string().nullable().optional(),
});

const AnswerAndExplanation = z.object({
  answer: z.string(),
  explanation: z.string(),
});

const ReverseDescriptionSchema = z.object({
  deckName: z.string(),
  deckDescription: z.string().optional(),
  frontCardDescription: z.string(),
  backCardDescription: z.string(),
  explanationDescription: z.string().nullable().optional(),
});

const ReverseDescriptionOutput = z.object({
  reverseFrontDescription: z.string(),
});



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

      // Generate the answer and explanation using the AI model with structured output
      const { output } = await ai.generate({
        system: `You are a flashcard creation assistant. Given a question and specific descriptions for the front and back of cards, provide a concise and informative answer suitable for a flashcard.

The descriptions provided will guide you on what content should appear on the front and back of cards. Follow these descriptions precisely to ensure consistency with the deck.

When providing an explanation, you can use markdown formatting. The explanation should be brief and relevant to the answer. If no specific explanation description is provided, provide a brief, helpful explanation that adds value to the learning experience.

OUTPUT STRUCTURE:
- "answer": The main response to the question (should follow the back card description)
- "explanation": Additional context or details (should follow the explanation description if provided, or provide a brief helpful explanation if none specified)`,
        prompt: `Question: ${subject.cardQuestion}
Deck name: ${subject.deckName}
Deck description: ${subject.deckDescription || ''}
Front card description: ${subject.frontCardDescription}
Back card description: ${subject.backCardDescription}
${subject.explanationDescription ? `Explanation description: ${subject.explanationDescription}` : 'Explanation description: Explanations are not required for these cards. Provide a brief, helpful explanation if it adds value to the learning experience.'}

IMPORTANT INSTRUCTIONS:
- Generate an "answer" that follows the back card description
- Generate an "explanation" that follows the explanation description (if provided)
- The answer should be the main response to the question
- The explanation should provide additional context, details, or clarification`,
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

// Genkit flow to generate reverse front description
const reverseDescriptionFlow = ai.defineFlow(
  {
    name: "reverseDescriptionFlow",
    inputSchema: ReverseDescriptionSchema,
    outputSchema: ReverseDescriptionOutput,
  },
  async (subject: any) => {
    try {
      console.log('Starting reverseDescriptionFlow with input:', JSON.stringify(subject, null, 2));

      // Generate the reverse description using the AI model
      const { output } = await ai.generate({
        system: `You are a flashcard description assistant. Your task is to generate a "reverse front description" for language learning decks.

This description will be used when users enter the back of a card (e.g., a word in the target language) and the system needs to generate the corresponding front (e.g., the native language translation).

Generate a clear, specific description that will help the AI create direct translations. The description MUST be in English for consistency with AI prompts and should be actionable for AI generation.

For language learning scenarios, focus on generating direct translations that provide the native language equivalent of the target language word or phrase.`,
        prompt: `Deck name: ${subject.deckName}
Deck description: ${subject.deckDescription || ''}
Front card description: ${subject.frontCardDescription}
Back card description: ${subject.backCardDescription}
${subject.explanationDescription ? `Explanation description: ${subject.explanationDescription}` : 'Explanation description: Explanations are not required for these cards.'}

SCENARIO: In this language learning deck, users can enter either the front or back of a card. When they enter the back of a card (e.g., a Spanish word like "gitano"), the system needs to generate the corresponding front (e.g., "cygan" - the Polish translation).

TASK: Generate a detailed "reverse front description" that will be used as the front card description when the user enters the back of a card. This description should be specific enough to generate direct translations that match the back card content.

REQUIREMENTS:
- The description MUST be generated in English for consistency with AI prompts
- It should be specific and actionable for AI generation
- It should complement the existing front and back descriptions
- For language learning, it should focus on generating direct translations (not questions)
- The description should instruct the AI to provide the native language equivalent of the target language word
- Make it clear that the output should be a direct translation, not a question
- The description should be clear and concise for optimal AI performance`,
        config: {
          temperature: 0.7,
        },
        output: {
          schema: ReverseDescriptionOutput,
        },
      });

      if (!output) {
        throw new Error("AI model did not return a response");
      }

      const result = output as { reverseFrontDescription: string };
      console.log('Reverse description flow completed successfully:', result);
      return result;

    } catch (error) {
      console.error('Error in reverseDescriptionFlow:', error);
      console.error('Error stack:', error instanceof Error ? error.stack : 'No stack trace');
      console.error('Input that caused error:', JSON.stringify(subject, null, 2));

      // Return a fallback response instead of throwing
      return {
        reverseFrontDescription: "Generate a question that asks for the target language word or phrase based on the provided context.",
      };
    }
  }
);

// Define Zod schemas for card description generation
const CardDescriptionGenerationInputSchema = z.object({
  deckName: z.string(),
  deckDescription: z.string().optional(),
  cards: z.array(z.object({
    question: z.string(),
    answer: z.string(),
    explanation: z.string().optional(),
  })).describe("Array of existing cards to analyze"),
  minCardsRequired: z.number().optional().describe("Minimum number of cards required for meaningful analysis (default: 3)"),
});

const CardDescriptionGenerationOutputSchema = z.object({
  frontCardDescription: z.string().nullable().describe("Description for what should appear on the front of cards, or null if not confident enough"),
  backCardDescription: z.string().nullable().describe("Description for what should appear on the back of cards, or null if not confident enough"),
  explanationDescription: z.string().nullable().optional().describe("Description for what should appear in explanations, or null if not confident enough"),
  confidence: z.number().describe("Confidence level of the generated descriptions (0-1)"),
  analysis: z.string().describe("Brief analysis of the card patterns found"),
});

// Define Zod schemas for generating front from back
const GenerateFrontFromBackInputSchema = z.object({
  deckName: z.string(),
  deckDescription: z.string().optional(),
  cardBack: z.string(),
  frontCardDescription: z.string(),
  backCardDescription: z.string(),
  explanationDescription: z.string().nullable().optional(),
});

const GenerateFrontFromBackOutputSchema = z.object({
  front: z.string(),
  explanation: z.string(),
});

// Genkit flow to generate the front of a card when the back is provided
const generateFrontFromBackFlow = ai.defineFlow(
  {
    name: "generateFrontFromBackFlow",
    inputSchema: GenerateFrontFromBackInputSchema,
    outputSchema: GenerateFrontFromBackOutputSchema,
  },
  async (subject: any) => {
    try {
      console.log('Starting generateFrontFromBackFlow with input:', JSON.stringify(subject, null, 2));

      // Generate the front using the AI model with structured output
      const { output } = await ai.generate({
        system: `You are a flashcard creation assistant. When a user provides the back of a card (e.g., a word in the target language), your task is to generate the corresponding front (e.g., the native language translation or question).

IMPORTANT CONTEXT:
- The user has provided the BACK of a card and wants you to generate the FRONT
- This is commonly used in language learning where users enter a target language word and need the native language equivalent
- Follow the front card description precisely to ensure consistency with the deck
- The output should be a direct translation or appropriate question, not a question asking for the back content

OUTPUT STRUCTURE:
- "front": The front of the card (should follow the front card description)
- "explanation": Additional context or details (should follow the explanation description if provided, or provide a brief helpful explanation if none specified)`,
        prompt: `Card Back: ${subject.cardBack}
Deck name: ${subject.deckName}
Deck description: ${subject.deckDescription || ''}
Front card description: ${subject.frontCardDescription}
Back card description: ${subject.backCardDescription}
${subject.explanationDescription ? `Explanation description: ${subject.explanationDescription}` : 'Explanation description: Explanations are not required for these cards. Provide a brief, helpful explanation if it adds value to the learning experience.'}

TASK: Generate the front of this card based on the provided back content.

INSTRUCTIONS:
- Generate a "front" that follows the front card description
- For language learning, this is typically a direct translation from the target language to the native language
- Generate an "explanation" that follows the explanation description (if provided)
- The front should be the main content that corresponds to the back
- The explanation should provide additional context, details, or clarification`,
        config: {
          temperature: 0.7,
        },
        output: {
          schema: GenerateFrontFromBackOutputSchema,
        },
      });

      if (!output) {
        throw new Error("AI model did not return a response");
      }

      const result = output as { front: string; explanation: string };
      console.log('Generate front from back flow completed successfully:', result);
      return result;

    } catch (error) {
      console.error('Error in generateFrontFromBackFlow:', error);
      console.error('Error stack:', error instanceof Error ? error.stack : 'No stack trace');
      console.error('Input that caused error:', JSON.stringify(subject, null, 2));

      // Return a fallback response instead of throwing
      return {
        front: "Error generating front. Please try again.",
        explanation: "The AI service encountered an error while processing your request.",
      };
    }
  }
);

// Genkit flow to generate card descriptions based on existing cards
const cardDescriptionGenerationFlow = ai.defineFlow(
  {
    name: "cardDescriptionGenerationFlow",
    inputSchema: CardDescriptionGenerationInputSchema,
    outputSchema: CardDescriptionGenerationOutputSchema,
  },
  async (subject: any) => {
    try {
      console.log('Starting cardDescriptionGenerationFlow with input:', JSON.stringify(subject, null, 2));

      const minCardsRequired = subject.minCardsRequired || 3;
      
      if (subject.cards.length < minCardsRequired) {
        return {
          frontCardDescription: null,
          backCardDescription: null,
          explanationDescription: null,
          confidence: 0,
          analysis: `Insufficient cards (${subject.cards.length}/${minCardsRequired}) for meaningful analysis.`,
        };
      }

      // Create a sample of cards for analysis (limit to avoid token limits)
      const sampleCards = subject.cards.slice(0, Math.min(10, subject.cards.length));
      
      // Generate descriptions using the AI model
      const { output } = await ai.generate({
        system: `You are a flashcard deck analysis assistant. Your task is to analyze existing cards in a deck and generate meaningful, precise descriptions for:
1. Front card description - what content should appear on the front of cards
2. Back card description - what content should appear on the back of cards  
3. Explanation description - what additional explanations should include

CONTEXT:
- This is for a flashcard learning system where users create decks
- Users have started creating their deck with the provided sample cards
- You need to generalize patterns from these cards to create descriptions that will guide future card generation
- The descriptions should be specific enough to ensure consistency but general enough to apply to new cards
- Descriptions should be in the same language as the deck name and description

ANALYSIS GUIDELINES:
- Look for patterns in question structure, answer format, and explanation style
- Consider the subject matter and difficulty level
- Identify the language(s) used if it's a language learning deck
- Determine if explanations are needed and what they typically contain
- Consider the educational level and complexity of the content

OUTPUT REQUIREMENTS:
- Front card description: Clear, specific instruction for what goes on the front. Return null if you cannot identify a clear pattern.
- Back card description: Clear, specific instruction for what goes on the back. Return null if you cannot identify a clear pattern.
- Explanation description: Only if explanations are consistently present and meaningful. Return null if explanations are inconsistent, rare, not meaningful, or if you cannot identify a clear pattern for explanations.
- Confidence: Rate your confidence in the analysis (0-1)
- Analysis: Brief explanation of the patterns you identified

IMPORTANT: Each field should be evaluated independently. If you're not confident about a specific field, return null for that field rather than providing a generic or unclear description. Only provide descriptions that are actionable and specific.

CRITICAL: For the explanation description, if explanations are not consistently present or meaningful in the sample cards, return null. Do not provide explanatory text about why explanations aren't needed - just return null.`,
        prompt: `Analyze the following flashcard deck and generate descriptions:

DECK INFORMATION:
- Name: ${subject.deckName}
- Description: ${subject.deckDescription || 'No description provided'}
- Number of cards analyzed: ${sampleCards.length} (out of ${subject.cards.length} total)

SAMPLE CARDS:
${sampleCards.map((card: any, index: number) => `
Card ${index + 1}:
- Front: "${card.question}"
- Back: "${card.answer}"
${card.explanation ? `- Explanation: "${card.explanation}"` : ''}`).join('\n')}

Please analyze these cards and generate:
1. A front card description that captures the pattern of what appears on the front
2. A back card description that captures the pattern of what appears on the back  
3. An explanation description (if explanations are consistently present and meaningful)
4. Your confidence level in this analysis
5. A brief analysis of the patterns you identified

Focus on creating descriptions that will help generate consistent, high-quality cards for this deck.`,
        config: {
          temperature: 0.3, // Lower temperature for more consistent analysis
        },
        output: {
          schema: CardDescriptionGenerationOutputSchema,
        },
      });

      if (!output) {
        throw new Error("AI model did not return a response");
      }

      const result = output as {
        frontCardDescription: string | null;
        backCardDescription: string | null;
        explanationDescription?: string | null;
        confidence: number;
        analysis: string;
      };

      console.log('Card description generation completed successfully:', result);
      return result;

    } catch (error) {
      console.error('Error in cardDescriptionGenerationFlow:', error);
      console.error('Error stack:', error instanceof Error ? error.stack : 'No stack trace');
      console.error('Input that caused error:', JSON.stringify(subject, null, 2));

      // Return a fallback response instead of throwing
      return {
        frontCardDescription: null,
        backCardDescription: null,
        explanationDescription: null,
        confidence: 0,
        analysis: "An error occurred during analysis. Please try again with a different set of cards.",
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

export const generateReverseDescription = onCallGenkit({
  secrets: [googleAIapiKey],
  region: "europe-central2"
},
  reverseDescriptionFlow);

export const generateCardDescriptions = onCallGenkit({
  secrets: [googleAIapiKey],
  region: "europe-central2"
},
  cardDescriptionGenerationFlow);

export const generateFrontFromBack = onCallGenkit({
  secrets: [googleAIapiKey],
  region: "europe-central2"
},
  generateFrontFromBackFlow);