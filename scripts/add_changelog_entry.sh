#!/bin/bash

# Script to add a new entry to CHANGELOG.yaml, bumping version and updating pubspec.yaml and firebase_remote_config.json
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }

# Default bump type
BUMP_TYPE="patch"
MESSAGE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --minor)
      BUMP_TYPE="minor"
      shift
      ;;
    --major)
      BUMP_TYPE="major"
      shift
      ;;
    --message)
      MESSAGE="$2"
      shift 2
      ;;
    *)
      if [ -z "$MESSAGE" ]; then
        MESSAGE="$1"
      fi
      shift
      ;;
  esac
done

if [ -z "$MESSAGE" ]; then
  print_error "A changelog message is required. Pass it as an argument or with --message."
  exit 1
fi

if [ ! -f CHANGELOG.yaml ]; then
  print_error "CHANGELOG.yaml not found."
  exit 1
fi

# Get latest version from CHANGELOG.yaml (assumes last entry is latest)
LATEST_VERSION=$(awk '/^- version:/ {print $3}' CHANGELOG.yaml | tail -1)
if [ -z "$LATEST_VERSION" ]; then
  print_error "Could not find a valid latest version in CHANGELOG.yaml."
  exit 1
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "$LATEST_VERSION"

case $BUMP_TYPE in
  patch)
    PATCH=$((PATCH + 1))
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
TODAY=$(date +%F)

print_info "Bumping version: $LATEST_VERSION -> $NEW_VERSION"

# Validate new version string (semantic versioning)
if ! [[ $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  print_error "Generated version $NEW_VERSION is not valid semantic versioning (X.Y.Z)."
  exit 1
fi

# Add new entry to CHANGELOG.yaml (always append with a blank line)
echo "" >> CHANGELOG.yaml
echo "- version: $NEW_VERSION" >> CHANGELOG.yaml
echo "  date: $TODAY" >> CHANGELOG.yaml
echo "  changes:" >> CHANGELOG.yaml
echo "    - $MESSAGE" >> CHANGELOG.yaml

print_success "Added new changelog entry for $NEW_VERSION." 