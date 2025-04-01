## Developing and testing Genkit functions

1. Export API key to env variable:
   Note: API key can be found in https://aistudio.google.com/app/apikey

    ```bash
    export GOOGLE_GENAI_API_KEY=<my key here>
    ```

2. Run Genkit local server. The server port is 4000 which conflicts with Firebase emulator.

    ```bash
    npm run genkit:start
    ```