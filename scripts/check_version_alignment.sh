#!/bin/bash

# check_version_alignment.sh: Checks if versions in CHANGELOG.yaml, pubspec.yaml, and firebase_remote_config.json are aligned

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Function to extract version from CHANGELOG.yaml
get_changelog_version() {
    if [ ! -f CHANGELOG.yaml ]; then
        print_error "CHANGELOG.yaml not found."
        return 1
    fi
    
    # Try using yq first, fallback to awk
    if command -v yq &> /dev/null; then
        yq '.[-1].version' CHANGELOG.yaml 2>/dev/null
    else
        awk '/^- version:/ {print $3}' CHANGELOG.yaml | tail -1
    fi
}

# Function to extract version from pubspec.yaml
get_pubspec_version() {
    if [ ! -f pubspec.yaml ]; then
        print_error "pubspec.yaml not found."
        return 1
    fi
    
    # Try using yq first, fallback to grep/awk
    if command -v yq &> /dev/null; then
        yq '.version' pubspec.yaml 2>/dev/null | cut -d'+' -f1
    else
        grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f1
    fi
}

# Function to extract version from firebase_remote_config.json
get_remote_config_version() {
    local config_file="${FIREBASE_REMOTE_CONFIG_JSON:-firebase_remote_config.json}"
    
    if [ ! -f "$config_file" ]; then
        print_error "$config_file not found."
        return 1
    fi
    
    # Try using jq first, fallback to grep/sed
    if command -v jq &> /dev/null; then
        jq -r '.parameters.app_version.defaultValue.value' "$config_file" 2>/dev/null
    else
        grep '"app_version"' "$config_file" | grep '"value"' | sed 's/.*"value": "\([^"]*\)".*/\1/'
    fi
}

# Main validation logic
main() {
    print_info "Checking version alignment across files..."
    
    # Get versions from all files
    CHANGELOG_VERSION=$(get_changelog_version)
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    PUBSPEC_VERSION=$(get_pubspec_version)
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    REMOTE_CONFIG_VERSION=$(get_remote_config_version)
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    # Display versions
    echo "CHANGELOG.yaml version: $CHANGELOG_VERSION"
    echo "pubspec.yaml version: $PUBSPEC_VERSION"
    echo "firebase_remote_config.json version: $REMOTE_CONFIG_VERSION"
    
    # Check if all versions match
    if [ "$CHANGELOG_VERSION" = "$PUBSPEC_VERSION" ] && [ "$CHANGELOG_VERSION" = "$REMOTE_CONFIG_VERSION" ]; then
        print_success "All versions are aligned: $CHANGELOG_VERSION"
        return 0
    else
        print_error "Version mismatch detected!"
        print_error "CHANGELOG.yaml: $CHANGELOG_VERSION"
        print_error "pubspec.yaml: $PUBSPEC_VERSION"
        print_error "firebase_remote_config.json: $REMOTE_CONFIG_VERSION"
        print_error "Please run './scripts/update_versions.sh' to align all versions."
        return 1
    fi
}

# Run main function
main "$@" 