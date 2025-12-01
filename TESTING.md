# Testing Process

This document describes the testing process for the Flutter Flashcards application, including automated checks and manual testing procedures.

## Code Quality Checks

We use `flutter analyze` to ensure code quality and adherence to coding standards.

### Running Analysis
```bash
flutter analyze
```
This command should be run before committing any changes to ensure no lint errors or warnings are introduced.

## Automated Testing

### Unit Tests
Unit tests cover business logic, state management, and repository implementations.

#### Running Unit Tests
```bash
flutter test
```

### Integration Tests
Integration tests cover end-to-end scenarios using Flutter Driver.

#### Running Integration Tests
(Requires a running emulator or device)
```bash
flutter drive --target=test_driver/app.dart
```

## Manual Testing

For manual testing during development, we support automatic login when running against the Firebase emulator.

### Prerequisites
- Firebase emulator running (usually via `./scripts/firebase_emulator.sh`)
- Flutter development environment set up

### Running with Auto-login
You can skip the manual login step by providing credentials via environment variables. This will automatically create the user if they don't exist in the emulator.

```bash
flutter run -d chrome --dart-define=AUTO_LOGIN_EMAIL=tester@test.com --dart-define=AUTO_LOGIN_PASSWORD=tester
```

### Verification Steps
1. Run the command above.
2. Verify the app opens and automatically logs in.
3. Verify you are redirected to the main decks page.
4. Try adding a new deck to verify database connectivity.
