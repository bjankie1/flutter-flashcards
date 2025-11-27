#!/bin/bash

# Colors for output
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

# Check if --prod flag is provided
USE_PROD_FIREBASE=false
if [[ "$*" == *"--prod"* ]]; then
    USE_PROD_FIREBASE=true
    print_warning "Running with PRODUCTION Firebase!"
    print_warning "This will connect to your production Firebase project!"
    print_warning "Make sure you want to use production data."
fi

# Build the Flutter run command
FLUTTER_CMD="flutter run -d chrome"

if [ "$USE_PROD_FIREBASE" = true ]; then
    FLUTTER_CMD="$FLUTTER_CMD --dart-define=FORCE_PROD_FIREBASE=true --dart-define=USE_FIREBASE_EMULATOR=false"
    print_info "Starting web app with production Firebase..."
else
    print_info "Starting web app with Firebase emulator..."
fi

# Run the command
eval $FLUTTER_CMD
