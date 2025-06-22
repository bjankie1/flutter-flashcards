#!/bin/bash

# Firebase Remote Config API Update Script
# This script uses Firebase REST API to update Remote Config automatically

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

echo -e "${BLUE}🚀 Firebase Remote Config API Update Script${NC}"
echo "=========================================="

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}❌ jq is not installed. Please install it first:${NC}"
    echo "brew install jq  # macOS"
    echo "sudo apt-get install jq  # Ubuntu/Debian"
    exit 1
fi

# Check if curl is available
if ! command -v curl &> /dev/null; then
    echo -e "${RED}❌ curl is not installed.${NC}"
    exit 1
fi

# Get current version from pubspec.yaml
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
VERSION_NUMBER=$(echo $VERSION | cut -d'+' -f1)
BUILD_NUMBER=$(echo $VERSION | cut -d'+' -f2)

echo -e "${GREEN}📦 Current version: $VERSION_NUMBER+$BUILD_NUMBER${NC}"

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

# Create Remote Config JSON
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
  }
}
EOF

echo -e "${GREEN}✅ Created Remote Config file: $CONFIG_FILE${NC}"

# Instructions for API usage
echo -e "${YELLOW}📝 API Update Instructions:${NC}"
echo "To use the Firebase REST API, you need:"
echo ""
echo "1. A Firebase Admin SDK service account key"
echo "2. Or use gcloud CLI for authentication"
echo ""
echo "Option 1: Using gcloud CLI (Recommended)"
echo "----------------------------------------"
echo "1. Install gcloud CLI and authenticate:"
echo "   gcloud auth login"
echo "   gcloud config set project $PROJECT_ID"
echo ""
echo "2. Get an access token:"
echo "   gcloud auth print-access-token"
echo ""
echo "3. Use the token to update Remote Config:"
echo "   curl -X PUT \\"
echo "     -H \"Authorization: Bearer \$(gcloud auth print-access-token)\" \\"
echo "     -H \"Content-Type: application/json\" \\"
echo "     -d @$CONFIG_FILE \\"
echo "     \"https://firebaseremoteconfig.googleapis.com/v1/projects/$PROJECT_ID/remoteConfig\""
echo ""
echo "Option 2: Using Firebase Admin SDK"
echo "----------------------------------"
echo "1. Create a service account key in Firebase Console"
echo "2. Use the Admin SDK to publish the config"
echo "3. See: https://firebase.google.com/docs/remote-config/use-config-rest"
echo ""

# Show the configuration
echo -e "${BLUE}📋 Remote Config Summary:${NC}"
echo "  Version: $VERSION_NUMBER"
echo "  Build: $BUILD_NUMBER"
echo "  Message: $CUSTOM_MESSAGE"
echo "  Required: $UPDATE_REQUIRED_VALUE"
echo ""

echo -e "${GREEN}🎉 Remote Config preparation complete!${NC}"
echo ""
echo -e "${BLUE}💡 Next steps:${NC}"
echo "  1. Use the API instructions above to update Remote Config"
echo "  2. Or update manually in Firebase Console"
echo "  3. Deploy your app with: ./deploy.sh"
echo "  4. Test the update notification" 