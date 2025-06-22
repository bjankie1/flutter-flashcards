# GitHub Actions Setup for Firebase Deployment

This guide will help you set up automated deployment to Firebase Hosting using GitHub Actions.

## 🚀 Overview

The GitHub Actions workflow will:
- ✅ Run tests on every push and pull request
- ✅ Deploy to Firebase Hosting on merge to main branch
- ✅ Automatically bump version numbers
- ✅ Update Firebase Remote Config
- ✅ Provide deployment summaries

## 📋 Prerequisites

1. **Firebase Project**: Already set up (`flashcards-521f0`)
2. **GitHub Repository**: Your Flutter app repository
3. **Firebase CLI**: Installed locally for initial setup
4. **Flutter SDK**: Version 3.32.4 or higher (supports Dart 3.8.0+)

## 🔧 Step 1: Create Firebase Service Account

### 1.1 Generate Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `flashcards-521f0`
3. Go to **Project Settings** → **Service Accounts**
4. Click **Generate new private key**
5. Download the JSON file (e.g., `firebase-service-account.json`)

### 1.2 Service Account Permissions

The service account needs these permissions:
- **Firebase Hosting**: Deploy to hosting
- **Firebase Remote Config**: Read and write config
- **Cloud Build**: Build and deploy (if using)

## 🔐 Step 2: Configure GitHub Secrets

### 2.1 Add Repository Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `FIREBASE_SERVICE_ACCOUNT_FLASHCARDS` | `{...}` | The entire JSON content of your Firebase service account key |

### 2.2 How to Add the Secret

1. **Copy the entire JSON content** from your `firebase-service-account.json` file
2. **Paste it as the secret value** (the entire JSON object)
3. **Click "Add secret"**

Example of what the secret should contain:
```json
{
  "type": "service_account",
  "project_id": "flashcards-521f0",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@flashcards-521f0.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40flashcards-521f0.iam.gserviceaccount.com"
}
```

## 🔄 Step 3: Configure Firebase Project

### 3.1 Initialize Firebase (if not already done)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project
firebase init hosting

# Select your project: flashcards-521f0
# Set public directory: build/web
# Configure as single-page app: Yes
# Set up automatic builds: No
```

### 3.2 Verify firebase.json

Ensure your `firebase.json` looks like this:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

## 🧪 Step 4: Test the Workflow

### 4.1 Push to Main Branch

1. **Commit and push** your changes to the main branch:
   ```bash
   git add .
   git commit -m "Add GitHub Actions workflow"
   git push origin main
   ```

2. **Check the workflow**:
   - Go to your GitHub repository
   - Click **Actions** tab
   - You should see the workflow running

### 4.2 Monitor the Deployment

The workflow will:
1. ✅ Run tests
2. ✅ Bump version number
3. ✅ Build the web app
4. ✅ Deploy to Firebase Hosting
5. ✅ Update Remote Config
6. ✅ Create deployment summary

## 🔍 Step 5: Verify Deployment

### 5.1 Check Live Site

- **Live URL**: https://flashcards-521f0.web.app
- **Firebase Console**: https://console.firebase.google.com/project/flashcards-521f0

### 5.2 Verify Remote Config

1. Go to Firebase Console → Remote Config
2. Check that the version parameters are updated
3. Verify the update notification works

## 🚨 Troubleshooting

### Common Issues

1. **Service Account Permission Error**:
   ```
   Error: 403 Forbidden
   ```
   **Solution**: Ensure the service account has proper permissions

2. **Firebase CLI Not Found**:
   ```
   Error: firebase command not found
   ```
   **Solution**: The workflow uses the Firebase Action, not CLI

3. **Version Bump Fails**:
   ```
   Error: mag command not found
   ```
   **Solution**: The workflow installs mag CLI automatically

4. **Remote Config Update Fails**:
   ```
   Error: 401 Unauthorized
   ```
   **Solution**: Check service account key and permissions

### Debug Steps

1. **Check GitHub Actions logs**:
   - Go to Actions tab
   - Click on the failed workflow
   - Check the specific step that failed

2. **Verify secrets**:
   - Ensure the service account JSON is complete
   - Check for extra spaces or formatting issues

3. **Test locally**:
   ```bash
   # Test Firebase deployment locally
   firebase deploy --only hosting
   
   # Test Remote Config update
   ./update_remote_config_api.sh
   ```

## 🔧 Customization

### Environment Variables

You can customize the workflow by modifying these variables in `.github/workflows/deploy.yml`:

```yaml
env:
  FLUTTER_VERSION: '3.32.4'  # Change Flutter version
  FIREBASE_PROJECT_ID: flashcards-521f0  # Change project ID
```

### Deployment Triggers

Modify the triggers in the workflow:

```yaml
on:
  push:
    branches: [main]  # Add more branches
  pull_request:
    branches: [main]  # Add more branches
  # Add manual trigger
  workflow_dispatch:
```

### Custom Update Messages

To customize the update message, modify this section in the workflow:

```yaml
"update_message": {
  "defaultValue": {
    "value": "New version available with latest features and improvements!"
  }
}
```

## 📊 Monitoring

### GitHub Actions Dashboard

- **Repository Actions**: Monitor all workflows
- **Deployment History**: Track version deployments
- **Build Logs**: Debug failed deployments

### Firebase Console

- **Hosting**: View deployment history
- **Remote Config**: Monitor version updates
- **Analytics**: Track user adoption

## 🔒 Security Best Practices

1. **Service Account Security**:
   - Never commit service account keys to repository
   - Use GitHub Secrets for sensitive data
   - Rotate keys regularly

2. **Repository Security**:
   - Enable branch protection on main
   - Require pull request reviews
   - Enable status checks

3. **Firebase Security**:
   - Use least privilege principle
   - Monitor service account usage
   - Enable audit logging

## 🎉 Success!

Once configured, your deployment process will be:

1. **Develop** → Push to feature branch
2. **Review** → Create pull request
3. **Test** → GitHub Actions runs tests
4. **Merge** → Automatic deployment to production
5. **Monitor** → Check deployment status and user adoption

The workflow ensures consistent, reliable deployments with proper version management and update notifications! 