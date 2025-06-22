#!/bin/bash

# GitHub Actions Setup Script for Firebase Deployment
# This script helps set up the automated deployment workflow

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_ID="flashcards-521f0"
FLUTTER_VERSION="3.32.4"

echo -e "${BLUE}🚀 GitHub Actions Setup for Firebase Deployment${NC}"
echo "=============================================="
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository. Please run this script from your project root.${NC}"
    exit 1
fi

# Check if we're connected to a remote repository
if ! git remote get-url origin > /dev/null 2>&1; then
    echo -e "${RED}❌ No remote repository found. Please add a GitHub remote:${NC}"
    echo "git remote add origin https://github.com/yourusername/your-repo.git"
    exit 1
fi

echo -e "${GREEN}✅ Git repository detected${NC}"

# Check if .github/workflows directory exists
if [ ! -d ".github/workflows" ]; then
    echo -e "${YELLOW}📁 Creating .github/workflows directory...${NC}"
    mkdir -p .github/workflows
fi

# Check if deploy.yml already exists
if [ -f ".github/workflows/deploy.yml" ]; then
    echo -e "${YELLOW}⚠️  GitHub Actions workflow already exists${NC}"
    read -p "Do you want to overwrite it? (y/N): " OVERWRITE
    if [[ ! $OVERWRITE =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}📝 Skipping workflow creation${NC}"
    else
        echo -e "${YELLOW}📝 Overwriting existing workflow...${NC}"
    fi
else
    OVERWRITE="y"
fi

if [[ $OVERWRITE =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}✅ GitHub Actions workflow will be created${NC}"
fi

echo ""
echo -e "${BLUE}📋 Setup Checklist:${NC}"
echo ""

# Step 1: Firebase Service Account
echo -e "${YELLOW}1. Firebase Service Account Setup${NC}"
echo "   - Go to: https://console.firebase.google.com/project/$PROJECT_ID/settings/serviceaccounts/adminsdk"
echo "   - Click 'Generate new private key'"
echo "   - Download the JSON file"
echo "   - Keep it secure (don't commit to git)"
echo ""

# Step 2: GitHub Secrets
echo -e "${YELLOW}2. GitHub Repository Secrets${NC}"
echo "   - Go to your GitHub repository"
echo "   - Navigate to: Settings → Secrets and variables → Actions"
echo "   - Click 'New repository secret'"
echo "   - Name: FIREBASE_SERVICE_ACCOUNT_FLASHCARDS"
echo "   - Value: Copy the entire JSON content from step 1"
echo ""

# Step 3: Verify Firebase Configuration
echo -e "${YELLOW}3. Verify Firebase Configuration${NC}"
if [ -f "firebase.json" ]; then
    echo -e "${GREEN}   ✅ firebase.json found${NC}"
    if grep -q '"hosting"' firebase.json; then
        echo -e "${GREEN}   ✅ Hosting configuration found${NC}"
    else
        echo -e "${RED}   ❌ Hosting configuration missing${NC}"
        echo "   Run: firebase init hosting"
    fi
else
    echo -e "${RED}   ❌ firebase.json not found${NC}"
    echo "   Run: firebase init"
fi
echo ""

# Step 4: Test Local Deployment
echo -e "${YELLOW}4. Test Local Deployment${NC}"
echo "   Before pushing to GitHub, test locally:"
echo "   - flutter build web"
echo "   - firebase deploy --only hosting"
echo ""

# Step 5: Push to GitHub
echo -e "${YELLOW}5. Push to GitHub${NC}"
echo "   After completing steps 1-4:"
echo "   - git add ."
echo "   - git commit -m 'Add GitHub Actions workflow'"
echo "   - git push origin main"
echo ""

# Step 6: Monitor Deployment
echo -e "${YELLOW}6. Monitor Deployment${NC}"
echo "   - Go to your GitHub repository → Actions tab"
echo "   - Watch the workflow run"
echo "   - Check for any errors"
echo ""

echo -e "${BLUE}🔗 Useful Links:${NC}"
echo "   - Firebase Console: https://console.firebase.google.com/project/$PROJECT_ID"
echo "   - Live Site: https://$PROJECT_ID.web.app"
echo "   - Remote Config: https://console.firebase.google.com/project/$PROJECT_ID/remoteConfig"
echo ""

echo -e "${GREEN}🎉 Setup Instructions Complete!${NC}"
echo ""
echo -e "${BLUE}💡 Next Steps:${NC}"
echo "1. Follow the checklist above"
echo "2. Test the deployment locally"
echo "3. Push to GitHub and monitor the workflow"
echo "4. Verify the live site and Remote Config updates"
echo ""

# Check if user wants to proceed with any automated steps
read -p "Do you want to test the local build now? (y/N): " TEST_BUILD

if [[ $TEST_BUILD =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🔨 Testing local build...${NC}"
    
    # Check if Flutter is available
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}❌ Flutter not found. Please install Flutter first.${NC}"
        exit 1
    fi
    
    # Get dependencies
    echo -e "${BLUE}📦 Getting dependencies...${NC}"
    flutter pub get
    
    # Build web app
    echo -e "${BLUE}🔨 Building web app...${NC}"
    flutter build web --source-maps
    
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
    echo -e "${BLUE}📁 Build output: build/web/${NC}"
    
    # Check if Firebase CLI is available
    if command -v firebase &> /dev/null; then
        read -p "Do you want to test Firebase deployment locally? (y/N): " TEST_DEPLOY
        
        if [[ $TEST_DEPLOY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}🚀 Testing Firebase deployment...${NC}"
            firebase deploy --only hosting
            
            echo -e "${GREEN}✅ Local deployment test completed!${NC}"
            echo -e "${BLUE}🌐 Live site: https://$PROJECT_ID.web.app${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Firebase CLI not found. Install with: npm install -g firebase-tools${NC}"
    fi
fi

echo ""
echo -e "${GREEN}🎉 Setup script completed!${NC}"
echo -e "${BLUE}📚 For detailed instructions, see: GITHUB_SETUP.md${NC}" 