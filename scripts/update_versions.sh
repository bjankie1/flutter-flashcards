#!/bin/bash

# update_versions.sh: Aligns pubspec.yaml and firebase_remote_config.json to the latest version in CHANGELOG.yaml

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

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

# Update firebase_remote_config.json parameters using jq
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
    
    # Extract build number from pubspec.yaml
    BUILD_NUMBER=$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f2)
    if [ -z "$BUILD_NUMBER" ]; then
        BUILD_NUMBER="1"
        print_warning "Could not extract build number from pubspec.yaml, using default: $BUILD_NUMBER"
    fi
    
    # Update multiple parameters in firebase_remote_config.json
    jq ".parameters.app_version.defaultValue.value = \"$LATEST_VERSION\" | 
        .parameters.app_build_number.defaultValue.value = \"$BUILD_NUMBER\" |
        .parameters.minimum_version.defaultValue.value = \"$LATEST_VERSION\" |
        .parameters.minimum_build_number.defaultValue.value = \"$BUILD_NUMBER\"" \
        firebase_remote_config.json > firebase_remote_config.tmp && mv firebase_remote_config.tmp firebase_remote_config.json
    
    print_success "Updated firebase_remote_config.json:"
    print_success "  - app_version: $LATEST_VERSION"
    print_success "  - app_build_number: $BUILD_NUMBER"
    print_success "  - minimum_version: $LATEST_VERSION"
    print_success "  - minimum_build_number: $BUILD_NUMBER"
else
    print_error "firebase_remote_config.json not found."
    exit 1
fi

print_success "Versions aligned to $LATEST_VERSION." 