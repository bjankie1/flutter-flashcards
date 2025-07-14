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

# Run the Android app in hot reload mode, starting emulator if needed

print_info "Checking for Android emulator..."

# Function to get Android emulator device ID
get_android_device() {
    flutter devices 2>/dev/null | grep "emulator" | head -1 | awk -F'•' '{print $2}' | xargs
}

# Check if any Android emulator is running
ANDROID_DEVICE=$(get_android_device)

if [ -z "$ANDROID_DEVICE" ]; then
    print_info "No Android emulator running. Starting Pixel 7 API 35 Large emulator..."
    flutter emulators --launch Pixel_7_API_35_Large
    
    print_info "Waiting for emulator to boot up..."
    # Wait for emulator to be ready (up to 2 minutes)
    for i in {1..24}; do
        ANDROID_DEVICE=$(get_android_device)
        if [ -n "$ANDROID_DEVICE" ]; then
            print_success "Emulator is ready!"
            break
        fi
        print_info "Waiting for emulator... ($i/24)"
        sleep 5
    done
else
    print_info "Android emulator is already running."
fi

# Final check for Android device
ANDROID_DEVICE=$(get_android_device)

if [ -z "$ANDROID_DEVICE" ]; then
    print_warning "Error: No Android emulator device found!"
    print_info "Available devices:"
    flutter devices
    exit 1
fi

print_info "Using Android device: $ANDROID_DEVICE"

# Build the Flutter run command
FLUTTER_CMD="flutter run -d \"$ANDROID_DEVICE\" --hot"

if [ "$USE_PROD_FIREBASE" = true ]; then
    FLUTTER_CMD="$FLUTTER_CMD --dart-define=FORCE_PROD_FIREBASE=true --dart-define=USE_FIREBASE_EMULATOR=false"
    print_info "Starting Flutter app on Android emulator with production Firebase..."
else
    print_info "Starting Flutter app on Android emulator with Firebase emulator..."
fi

# Run the command
eval $FLUTTER_CMD 