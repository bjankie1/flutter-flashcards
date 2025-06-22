#!/bin/bash

# Deploy script for Flutter Flashcards App
# This script updates version numbers and deploys the app

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Flutter Flashcards Deployment Script${NC}"
echo "======================================"

# Check if bump_version.sh exists and is executable
if [ ! -x "./scripts/bump_version.sh" ]; then
    echo -e "${RED}❌ Error: scripts/bump_version.sh not found or not executable${NC}"
    echo "Please ensure the script exists and has execute permissions:"
    echo "  chmod +x scripts/bump_version.sh"
    exit 1
fi

# Bump version number using our script
echo -e "${YELLOW}📦 Bumping version number...${NC}"
./scripts/bump_version.sh

# Get version information from environment variables set by the script
if [ -z "$VERSION" ] || [ -z "$VERSION_NUMBER" ] || [ -z "$BUILD_NUMBER" ]; then
    # Fallback: read from pubspec.yaml if environment variables are not set
    VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
    VERSION_NUMBER=$(echo $VERSION | cut -d'+' -f1)
    BUILD_NUMBER=$(echo $VERSION | cut -d'+' -f2)
fi

echo -e "${GREEN}✅ New version: $VERSION_NUMBER+$BUILD_NUMBER${NC}"

# Generate code
echo -e "${YELLOW}🔧 Generating code...${NC}"
dart run build_runner build --delete-conflicting-outputs

# Build the app
echo -e "${YELLOW}🔨 Building web app...${NC}"
flutter build web --source-maps

# Deploy to Firebase
echo -e "${YELLOW}🚀 Deploying to Firebase...${NC}"
firebase deploy

echo -e "${GREEN}✅ Deployment complete!${NC}"
echo ""
echo -e "${BLUE}📋 Deployment Summary:${NC}"
echo "  Version: $VERSION_NUMBER"
echo "  Build: $BUILD_NUMBER"
echo "  Deployed to: Firebase Hosting"
echo ""
echo -e "${YELLOW}⚠️  Important: Update Firebase Remote Config${NC}"
echo "  Run: ./update_remote_config.sh"
echo "  Or manually update in Firebase Console:"
echo "    - app_version: $VERSION_NUMBER"
echo "    - app_build_number: $BUILD_NUMBER"
echo ""
echo -e "${BLUE}💡 Next steps:${NC}"
echo "  1. Update Remote Config (if not done automatically)"
echo "  2. Test the update notification"
echo "  3. Monitor user update adoption"