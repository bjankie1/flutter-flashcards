#!/bin/sh

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

# Bump version number
echo -e "${YELLOW}📦 Bumping version number...${NC}"
mag modify bump --targets 'build-number'
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
VERSION_NUMBER=$(echo $VERSION | cut -d'+' -f1)
BUILD_NUMBER=$(echo $VERSION | cut -d'+' -f2)

echo -e "${GREEN}✅ New version: $VERSION_NUMBER+$BUILD_NUMBER${NC}"

# Update version in index.html
echo -e "${YELLOW}📝 Updating index.html...${NC}"
sed -i -e "s/\"flutter_bootstrap\.js[^\"]*\"/\"flutter_bootstrap.js?v=$VERSION\"/g" web/index.html

# Update service worker version
echo -e "${YELLOW}🔧 Updating service worker...${NC}"
sed -i -e "s/const CACHE_NAME = 'flutter-flashcards-v[^']*'/const CACHE_NAME = 'flutter-flashcards-v$VERSION'/g" web/sw.js
sed -i -e "s/const STATIC_CACHE_NAME = 'flutter-flashcards-static-v[^']*'/const STATIC_CACHE_NAME = 'flutter-flashcards-static-v$VERSION'/g" web/sw.js

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