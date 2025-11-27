# Firebase Configuration

This app supports flexible Firebase configuration to switch between emulator and production environments.

## Default Behavior

- **Debug mode**: Uses Firebase emulator by default
- **Release mode**: Always uses production Firebase

## Forcing Production Firebase in Debug Mode

Sometimes you need to test the app against production Firebase even in debug mode (e.g., for authentication testing).

### Option 1: Using Existing Scripts with --prod Flag

```bash
# Run web app with production Firebase
./scripts/run-web.sh --prod

# Run Android app with production Firebase
./scripts/run-android.sh --prod

# Run with emulator (default behavior)
./scripts/run-web.sh
./scripts/run-android.sh
```

### Option 2: Using the Standalone Script

```bash
# Run with production Firebase in debug mode
./scripts/run_with_prod_firebase.sh

# Run in release mode (always uses production)
./scripts/run_with_prod_firebase.sh --release
```

### Option 3: Using Flutter Run Directly

```bash
# Force production Firebase
flutter run --dart-define=FORCE_PROD_FIREBASE=true --dart-define=USE_FIREBASE_EMULATOR=false

# Or disable emulator only
flutter run --dart-define=USE_FIREBASE_EMULATOR=false
```

### Option 4: Environment Variables

You can also set environment variables:

```bash
export FORCE_PROD_FIREBASE=true
export USE_FIREBASE_EMULATOR=false
flutter run
```

## Configuration Options

The app uses the `AppConfig` class to determine Firebase configuration:

- `AppConfig.forceProductionFirebase`: Whether to force production Firebase
- `AppConfig.useFirebaseEmulator`: Whether to use Firebase emulator
- `AppConfig.showFirebaseUIAuth`: Whether to show Firebase UI auth components

## What Gets Affected

When forcing production Firebase:

1. **Firestore**: Connects to production database instead of emulator
2. **Authentication**: Uses production auth instead of emulator
3. **Storage**: Uses production storage instead of emulator
4. **Cloud Functions**: Uses production functions instead of emulator
5. **UI Components**: Shows custom login/signup forms instead of Firebase UI

## Safety Warnings

⚠️ **Warning**: When using production Firebase in debug mode:
- You will be working with real production data
- Any changes you make will affect the live database
- Make sure you understand the implications before proceeding

## Development Workflow

1. **Normal development**: Use emulator (default behavior)
   ```bash
   ./scripts/run-web.sh
   ./scripts/run-android.sh
   ```

2. **Testing production auth**: Use `--prod` flag
   ```bash
   ./scripts/run-web.sh --prod
   ./scripts/run-android.sh --prod
   ```

3. **Production deployment**: Always uses production Firebase automatically 