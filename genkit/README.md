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

3. Open Genkit AI console http://localhost:4000/ to test flows.

4. Check if code builds:

   ```bash
   npm run build 
   ```

5. Deploy functions.

   ```bash
   firebase deploy --only functions:genkit
   ```