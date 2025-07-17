## Developing and testing Genkit functions

### Local Development

1. Export API key to env variable for local development:
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

### Production Deployment

More info: https://genkit.dev/docs/firebase/

For production deployment, the API key should be stored as a Firebase Functions secret to prevent accidental exposure:

1. Store your API key in Firebase Functions secrets (do it once):
   ```bash
   firebase functions:secrets:set GEMINI_API_KEY
   ```
   When prompted, enter your API key from https://aistudio.google.com/app/apikey

2. Deploy functions:
   ```bash
   npm run deploy
   ```

### API Key Configuration

- **Local Development**: Uses environment variable `GOOGLE_GENAI_API_KEY`
- **Production**: Uses Firebase Functions secret `GEMINI_API_KEY` (configured in the code via `defineSecret`)
- **Source**: Get your API key from https://aistudio.google.com/app/apikey

The functions are configured to automatically use the appropriate API key source based on the environment.