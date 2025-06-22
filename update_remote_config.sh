#!/bin/bash

# Firebase Remote Config Update Script
# This script helps prepare Remote Config updates and provides instructions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID="flashcards-521f0"
CONFIG_FILE="remote_config.json"

echo -e "${BLUE}🚀 Firebase Remote Config Update Script${NC}"
echo "=================================="

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Firebase CLI is not installed. Please install it first:${NC}"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in to Firebase
if ! firebase projects:list &> /dev/null; then
    echo -e "${RED}❌ Not logged in to Firebase. Please run:${NC}"
    echo "firebase login"
    exit 1
fi

# Get current version from pubspec.yaml
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
VERSION_NUMBER=$(echo $VERSION | cut -d'+' -f1)
BUILD_NUMBER=$(echo $VERSION | cut -d'+' -f2)

echo -e "${GREEN}📦 Current version: $VERSION_NUMBER+$BUILD_NUMBER${NC}"

# Get current Remote Config
echo -e "${YELLOW}📥 Fetching current Remote Config...${NC}"
if firebase remoteconfig:get --project $PROJECT_ID --output current_config.json 2>/dev/null; then
    echo -e "${GREEN}✅ Current config fetched${NC}"
    CURRENT_CONFIG_EXISTS=true
else
    echo -e "${YELLOW}⚠️  No existing config found, will create new one${NC}"
    CURRENT_CONFIG_EXISTS=false
fi

# Prompt for custom update message
echo -e "${BLUE}💬 Enter custom update message (or press Enter for default):${NC}"
read -r CUSTOM_MESSAGE

if [ -z "$CUSTOM_MESSAGE" ]; then
    CUSTOM_MESSAGE="New version available with latest features and improvements!"
fi

# Prompt for update requirement
echo -e "${BLUE}🔒 Is this update required? (y/N):${NC}"
read -r UPDATE_REQUIRED

if [[ $UPDATE_REQUIRED =~ ^[Yy]$ ]]; then
    UPDATE_REQUIRED_VALUE="true"
    echo -e "${YELLOW}⚠️  Marked as required update${NC}"
else
    UPDATE_REQUIRED_VALUE="false"
    echo -e "${GREEN}✅ Marked as optional update${NC}"
fi

# Create updated Remote Config JSON
echo -e "${YELLOW}📝 Creating updated Remote Config...${NC}"

cat > $CONFIG_FILE << EOF
{
  "conditions": [
    {
      "name": "Default",
      "expression": "true",
      "tagColor": "BLUE"
    }
  ],
  "parameters": {
    "app_version": {
      "defaultValue": {
        "value": "$VERSION_NUMBER"
      },
      "description": "Current app version (semantic versioning)",
      "valueType": "STRING"
    },
    "app_build_number": {
      "defaultValue": {
        "value": "$BUILD_NUMBER"
      },
      "description": "Current app build number",
      "valueType": "STRING"
    },
    "update_message": {
      "defaultValue": {
        "value": "$CUSTOM_MESSAGE"
      },
      "description": "Custom message shown to users when update is available",
      "valueType": "STRING"
    },
    "update_required": {
      "defaultValue": {
        "value": "$UPDATE_REQUIRED_VALUE"
      },
      "description": "Whether the update is required (true) or optional (false)",
      "valueType": "STRING"
    }
  },
  "version": {
    "versionNumber": "1",
    "updateTime": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "updateUser": {
      "email": "deployment-script@example.com"
    },
    "updateOrigin": "CONSOLE",
    "updateType": "INCREMENTAL_UPDATE"
  }
}
EOF

echo -e "${GREEN}✅ Created Remote Config file: $CONFIG_FILE${NC}"

# Show the configuration
echo -e "${BLUE}📋 Remote Config Summary:${NC}"
echo "  Version: $VERSION_NUMBER"
echo "  Build: $BUILD_NUMBER"
echo "  Message: $CUSTOM_MESSAGE"
echo "  Required: $UPDATE_REQUIRED_VALUE"
echo ""

# Instructions for manual update
echo -e "${YELLOW}📝 Manual Update Instructions:${NC}"
echo "Since Firebase CLI doesn't support direct Remote Config publishing,"
echo "please follow these steps:"
echo ""
echo "1. Go to Firebase Console:"
echo "   https://console.firebase.google.com/project/$PROJECT_ID/remoteConfig"
echo ""
echo "2. Click 'Add your first parameter' or edit existing parameters"
echo ""
echo "3. Add/Update these parameters:"
echo "   - app_version: $VERSION_NUMBER"
echo "   - app_build_number: $BUILD_NUMBER"
echo "   - update_message: $CUSTOM_MESSAGE"
echo "   - update_required: $UPDATE_REQUIRED_VALUE"
echo ""
echo "4. Click 'Publish changes'"
echo ""

# Alternative: Show how to use the JSON file
echo -e "${BLUE}🔧 Alternative: Use the generated JSON file${NC}"
echo "You can also use the generated $CONFIG_FILE file:"
echo "1. Copy the contents of $CONFIG_FILE"
echo "2. Use Firebase Admin SDK or REST API to publish"
echo "3. Or import via Firebase Console"
echo ""

# Clean up
if [ "$CURRENT_CONFIG_EXISTS" = true ]; then
    rm -f current_config.json
fi

echo -e "${GREEN}🎉 Remote Config preparation complete!${NC}"
echo ""
echo -e "${BLUE}💡 Next steps:${NC}"
echo "  1. Update Remote Config manually in Firebase Console"
echo "  2. Deploy your app with: ./deploy.sh"
echo "  3. Test the update notification"
echo "  4. Monitor user update adoption" 