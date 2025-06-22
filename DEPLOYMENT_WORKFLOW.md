# Deployment Workflow for Flutter Flashcards

This document outlines the complete deployment workflow including Firebase Remote Config updates.

## 🚀 Deployment Options

### Option 0: GitHub Actions Automated Deployment (Recommended)

**Fully automated deployment triggered on merge to main branch**

1. **Setup** (one-time):
   ```bash
   ./setup_github_actions.sh
   ```
   Follow the setup guide in `GITHUB_SETUP.md`

2. **Deploy**:
   - Push changes to main branch
   - GitHub Actions automatically:
     - Runs tests
     - Bumps version
     - Builds and deploys to Firebase Hosting
     - Updates Remote Config
     - Provides deployment summary

3. **Monitor**:
   - Check GitHub Actions tab for status
   - Verify live site: https://flashcards-521f0.web.app
   - Monitor Remote Config updates

**Benefits**:
- ✅ Zero manual intervention
- ✅ Consistent deployments
- ✅ Automatic version management
- ✅ Built-in testing
- ✅ Deployment history tracking

### Option 1: Automated Deployment (Recommended)

1. **Run the deployment script**:
   ```bash
   ./deploy.sh
   ```

2. **Update Remote Config** (preparation):
   ```bash
   ./update_remote_config.sh
   ```

3. **Manually publish in Firebase Console**:
   - Follow the instructions provided by the script
   - Go to Firebase Console → Remote Config
   - Update the parameters as shown
   - Click "Publish changes"

### Option 2: API-Based Deployment (Advanced)

1. **Deploy the app**:
   ```bash
   ./deploy.sh
   ```

2. **Prepare Remote Config**:
   ```bash
   ./update_remote_config_api.sh
   ```

3. **Use gcloud CLI to update**:
   ```bash
   gcloud auth login
   gcloud config set project flashcards-521f0
   curl -X PUT \
     -H "Authorization: Bearer $(gcloud auth print-access-token)" \
     -H "Content-Type: application/json" \
     -d @remote_config.json \
     "https://firebaseremoteconfig.googleapis.com/v1/projects/flashcards-521f0/remoteConfig"
   ```

### Option 3: Manual Deployment

1. **Update version in pubspec.yaml**:
   ```yaml
   version: 1.0.3+122
   ```

2. **Deploy the app**:
   ```bash
   ./deploy.sh
   ```

3. **Manually update Firebase Remote Config**:
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Select your project: `flashcards-521f0`
   - Navigate to **Remote Config**
   - Update these parameters:

   | Parameter | Value | Description |
   |-----------|-------|-------------|
   | `app_version` | `1.0.3` | Semantic version |
   | `app_build_number` | `122` | Build number |
   | `update_message` | `New features and bug fixes!` | Custom message |
   | `update_required` | `false` | Force update flag |

## 📋 Pre-Deployment Checklist

- [ ] **Code Review**: All changes reviewed and tested
- [ ] **Version Bump**: Version number updated in `pubspec.yaml`
- [ ] **Changelog**: Update notes prepared for users
- [ ] **Testing**: App tested locally and in staging
- [ ] **Firebase CLI**: Logged in and configured
- [ ] **gcloud CLI**: Installed and authenticated (for API method)

## 🔧 Remote Config Parameters

### Required Parameters

```json
{
  "app_version": "1.0.3",
  "app_build_number": "122"
}
```

### Optional Parameters

```json
{
  "update_message": "New features and bug fixes available!",
  "update_required": "false"
}
```

### Parameter Descriptions

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `app_version` | String | ✅ | Semantic version (e.g., "1.0.3") |
| `app_build_number` | String | ✅ | Build number (e.g., "122") |
| `update_message` | String | ❌ | Custom message shown to users |
| `update_required` | String | ❌ | "true" for critical updates, "false" for optional |

## 🎯 Update Message Guidelines

### Good Update Messages
- ✅ "New features and bug fixes available!"
- ✅ "Performance improvements and UI enhancements"
- ✅ "Security updates and new learning features"
- ✅ "Bug fixes and stability improvements"

### Avoid These
- ❌ "Update now or else..."
- ❌ "Critical security vulnerability"
- ❌ "Your app will stop working"

## 🔄 Deployment Workflow Steps

### 1. Version Management
```bash
# The deploy script automatically bumps the build number
./deploy.sh
```

### 2. App Deployment
```bash
# Build and deploy to Firebase Hosting
flutter build web --source-maps
firebase deploy
```

### 3. Remote Config Update

#### Method A: Manual (Recommended for most users)
```bash
# Prepare the configuration
./update_remote_config.sh

# Then follow the instructions to update in Firebase Console
```

#### Method B: API (For advanced users)
```bash
# Prepare and update via API
./update_remote_config_api.sh

# Use gcloud CLI to authenticate and update
gcloud auth login
gcloud config set project flashcards-521f0
curl -X PUT \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d @remote_config.json \
  "https://firebaseremoteconfig.googleapis.com/v1/projects/flashcards-521f0/remoteConfig"
```

### 4. Verification
- [ ] App loads correctly in production
- [ ] Update notification appears for older versions
- [ ] Update process works correctly
- [ ] Service worker caches properly

## 🧪 Testing the Update System

### Test with Different Versions

1. **Set Remote Config to higher version**:
   ```json
   {
     "app_version": "1.0.4",
     "app_build_number": "123"
   }
   ```

2. **Load the app** (should show update banner)

3. **Test update process**:
   - Click "Update Now"
   - Verify app reloads
   - Check if banner disappears

### Test Update Messages

1. **Set custom message**:
   ```json
   {
     "update_message": "Test message for version checking"
   }
   ```

2. **Verify message appears in banner**

### Test Required Updates

1. **Set required flag**:
   ```json
   {
     "update_required": "true"
   }
   ```

2. **Verify different behavior** (if implemented)

## 📊 Monitoring and Analytics

### Key Metrics to Track

- **Update Adoption Rate**: Percentage of users who update
- **Update Time**: How long users take to update
- **Update Failure Rate**: Failed update attempts
- **User Engagement**: Usage patterns before/after updates

### Firebase Analytics Events

The app automatically tracks these events:
- `update_available`: When update is detected
- `update_dismissed`: When user dismisses update
- `update_started`: When user starts update
- `update_completed`: When update finishes
- `update_failed`: When update fails

## 🚨 Troubleshooting

### Common Issues

1. **Update not showing**:
   - Check Remote Config values
   - Verify version comparison logic
   - Clear browser cache
   - Check service worker registration

2. **Update banner not appearing**:
   - Ensure AppInfo is properly initialized
   - Check Firebase Remote Config fetch
   - Verify periodic checking is enabled

3. **Update process fails**:
   - Check JavaScript console for errors
   - Verify service worker is active
   - Test with different browsers

4. **Remote Config update fails**:
   - Ensure you're logged into Firebase Console
   - Check project permissions
   - Verify parameter names and values
   - Try the API method if console fails

### Debug Commands

```bash
# Check current Remote Config
firebase remoteconfig:get --project flashcards-521f0

# View Remote Config history
firebase remoteconfig:versions:list --project flashcards-521f0

# Test Remote Config locally
flutter run -d chrome --web-port=8080

# Check gcloud authentication
gcloud auth list
gcloud config get-value project
```

## 🔐 Security Considerations

- **Version information is public**: No sensitive data in version numbers
- **Update checks are safe**: Only version comparison, no user data
- **Service worker security**: Runs in isolated context
- **Firebase security**: Uses Firebase security rules
- **API authentication**: Uses gcloud or service account authentication

## 📈 Best Practices

1. **Regular Updates**: Deploy updates regularly (weekly/monthly)
2. **Clear Messages**: Use clear, positive update messages
3. **Gradual Rollouts**: Use Firebase Remote Config for gradual rollouts
4. **Monitor Metrics**: Track update adoption and user feedback
5. **Test Thoroughly**: Always test update process before deployment
6. **Backup Config**: Keep backup of Remote Config before major changes

## 🔄 CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter build web
      - run: firebase deploy
      - uses: google-github-actions/auth@v0
        with:
          credentials_json: ${{ secrets.FIREBASE_SERVICE_ACCOUNT_KEY }}
      - run: |
          ./update_remote_config_api.sh
          curl -X PUT \
            -H "Authorization: Bearer $(gcloud auth print-access-token)" \
            -H "Content-Type: application/json" \
            -d @remote_config.json \
            "https://firebaseremoteconfig.googleapis.com/v1/projects/flashcards-521f0/remoteConfig"
```

This workflow ensures consistent deployments with automatic Remote Config updates.

## 🛠️ Tools and Scripts

### Available Scripts

- `deploy.sh`: Main deployment script
- `update_remote_config.sh`: Prepare Remote Config for manual update
- `update_remote_config_api.sh`: Prepare Remote Config for API update

### Prerequisites

- Firebase CLI: `npm install -g firebase-tools`
- gcloud CLI: For API-based updates
- jq: For JSON processing (optional)
- curl: For API calls (optional)

This comprehensive workflow ensures reliable deployments with proper version management and update notifications. 