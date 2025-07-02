#!/bin/bash

# Version bump script for Flutter Flashcards
# This script increments the build number in pubspec.yaml and outputs version information

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if pubspec.yaml exists
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found in current directory"
    exit 1
fi

# Read current version from pubspec.yaml
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')

if [ -z "$CURRENT_VERSION" ]; then
    print_error "Could not find version in pubspec.yaml"
    exit 1
fi

# Parse version components
VERSION_NUMBER=$(echo $CURRENT_VERSION | cut -d'+' -f1)
CURRENT_BUILD=$(echo $CURRENT_VERSION | cut -d'+' -f2)

# Validate build number is numeric
if ! [[ "$CURRENT_BUILD" =~ ^[0-9]+$ ]]; then
    print_error "Invalid build number: $CURRENT_BUILD"
    exit 1
fi

# Increment build number
NEW_BUILD=$((CURRENT_BUILD + 1))
NEW_VERSION="${VERSION_NUMBER}+${NEW_BUILD}"

print_info "Current version: $CURRENT_VERSION"
print_info "New version: $NEW_VERSION"

# Update pubspec.yaml with new version
sed -i '' "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml

if [ $? -eq 0 ]; then
    print_success "Updated pubspec.yaml with version $NEW_VERSION"
else
    print_error "Failed to update pubspec.yaml"
    exit 1
fi

# Output version information for GitHub Actions
if [ -n "$GITHUB_ENV" ]; then
    echo "VERSION=$NEW_VERSION" >> $GITHUB_ENV
    echo "VERSION_NUMBER=$VERSION_NUMBER" >> $GITHUB_ENV
    echo "BUILD_NUMBER=$NEW_BUILD" >> $GITHUB_ENV
fi

print_success "Version bumped successfully!"
print_info "Version: $VERSION_NUMBER"
print_info "Build: $NEW_BUILD"
print_info "Full version: $NEW_VERSION"

# Optional: Update web files if they exist
if [ -f "web/index.html" ]; then
    sed -i '' -e "s/\"flutter_bootstrap\.js[^\"]*\"/\"flutter_bootstrap.js?v=$NEW_VERSION\"/g" web/index.html
    print_info "Updated web/index.html"
fi

if [ -f "web/sw.js" ]; then
    sed -i '' -e "s/const CACHE_NAME = 'flutter-flashcards-v[^']*'/const CACHE_NAME = 'flutter-flashcards-v$NEW_VERSION'/g" web/sw.js
    sed -i '' -e "s/const STATIC_CACHE_NAME = 'flutter-flashcards-static-v[^']*'/const STATIC_CACHE_NAME = 'flutter-flashcards-static-v$NEW_VERSION'/g" web/sw.js
    print_info "Updated web/sw.js"
fi 