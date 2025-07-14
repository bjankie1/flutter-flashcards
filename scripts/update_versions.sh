#!/bin/bash

# update_versions.sh: Aligns pubspec.yaml and firebase_remote_config.json to the latest version in CHANGELOG.yaml

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Get latest version from CHANGELOG.yaml
if [ ! -f CHANGELOG.yaml ]; then
    print_error "CHANGELOG.yaml not found."
    exit 1
fi
LATEST_VERSION=$(awk '/^- version:/ {print $3}' CHANGELOG.yaml | tail -1)
if [ -z "$LATEST_VERSION" ]; then
    print_error "Could not find a valid latest version in CHANGELOG.yaml."
    exit 1
fi
print_info "Latest version from CHANGELOG.yaml: $LATEST_VERSION"

# Update pubspec.yaml
if [ -f pubspec.yaml ]; then
    # Try using yq first, fallback to sed
    if command -v yq &> /dev/null; then
        yq ".version = \"$LATEST_VERSION+1\"" pubspec.yaml > pubspec.tmp && mv pubspec.tmp pubspec.yaml
        print_success "Updated pubspec.yaml to version $LATEST_VERSION+1 using yq."
    else
        # Use platform-specific sed syntax as fallback
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^version: .*/version: $LATEST_VERSION+1/" pubspec.yaml
        else
            sed -i "s/^version: .*/version: $LATEST_VERSION+1/" pubspec.yaml
        fi
        print_success "Updated pubspec.yaml to version $LATEST_VERSION+1 using sed."
    fi
else
    print_error "pubspec.yaml not found."
    exit 1
fi

# Update firebase_remote_config.json app_version using jq
if [ -f firebase_remote_config.json ]; then
    # Safeguard: check if file appears to be JSON
    if [[ "$(head -n 1 firebase_remote_config.json)" != *"{"* ]]; then
        print_error "firebase_remote_config.json does not appear to be a JSON file. Aborting."
        exit 1
    fi
    if ! command -v jq &> /dev/null; then
        print_error "jq is required to update firebase_remote_config.json. Please install jq."
        exit 1
    fi
    jq ".parameters.app_version.defaultValue.value = \"$LATEST_VERSION\"" firebase_remote_config.json > firebase_remote_config.tmp && mv firebase_remote_config.tmp firebase_remote_config.json
    print_success "Updated firebase_remote_config.json app_version to $LATEST_VERSION using jq."
else
    print_error "firebase_remote_config.json not found."
    exit 1
fi

print_success "Versions aligned to $LATEST_VERSION." 