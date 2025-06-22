# Scripts Directory

This directory contains utility scripts for the Flutter Flashcards project.

## bump_version.sh

A shell script that automatically increments the build number in `pubspec.yaml` and updates related files.

### Features

- ✅ Increments build number in `pubspec.yaml`
- ✅ Updates version references in `web/index.html`
- ✅ Updates cache names in `web/sw.js`
- ✅ Sets environment variables for CI/CD
- ✅ Colored output for better readability
- ✅ Error handling and validation
- ✅ Works both locally and in GitHub Actions

### Usage

#### Local Development
```bash
# Make sure the script is executable
chmod +x scripts/bump_version.sh

# Run the script from the project root
./scripts/bump_version.sh
```

#### GitHub Actions
The script is automatically called during deployment in `.github/workflows/deploy.yml`.

#### Manual Deployment
The script is also used by the main deployment script `deploy.sh` for manual deployments.

### Example Output
```
[INFO] Current version: 1.0.2+121
[INFO] New version: 1.0.2+122
[SUCCESS] Updated pubspec.yaml with version 1.0.2+122
[INFO] Updated web/index.html
[INFO] Updated web/sw.js
[SUCCESS] Version bumped successfully!
[INFO] Version: 1.0.2
[INFO] Build: 122
[INFO] Full version: 1.0.2+122
```

### Environment Variables Set

The script sets the following environment variables for use in CI/CD:

- `VERSION`: Full version string (e.g., "1.0.2+122")
- `VERSION_NUMBER`: Semantic version (e.g., "1.0.2")
- `BUILD_NUMBER`: Build number (e.g., "122")

### Error Handling

The script includes comprehensive error handling:

- Validates that `pubspec.yaml` exists
- Ensures version format is correct
- Validates build number is numeric
- Checks for successful file updates
- Exits with appropriate error codes

### Requirements

- Bash shell
- `sed` command (available on most Unix-like systems)
- `grep` and `awk` for text processing
- Write permissions to `pubspec.yaml` and web files

## deploy.sh

A comprehensive deployment script that handles the entire deployment process.

### Features

- ✅ Uses `bump_version.sh` for version management
- ✅ Builds the Flutter web app
- ✅ Deploys to Firebase Hosting
- ✅ Provides deployment summary
- ✅ Includes helpful next steps

### Usage

```bash
# Make sure the script is executable
chmod +x deploy.sh

# Run the deployment script
./deploy.sh
```

### What it does

1. **Version Bumping**: Calls `bump_version.sh` to increment build number
2. **Building**: Runs `flutter build web --source-maps`
3. **Deployment**: Deploys to Firebase using `firebase deploy`
4. **Summary**: Provides deployment information and next steps

### Requirements

- Flutter SDK installed and configured
- Firebase CLI installed and authenticated
- `bump_version.sh` script available and executable 