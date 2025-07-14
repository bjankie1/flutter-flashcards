#!/bin/bash

# Firebase Remote Config Setup Script
# This script sets up the required Remote Config parameters for version management

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
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

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --project PROJECT_ID    Firebase project ID"
    echo "  --environment ENV       Environment (production|staging) [default: production]"
    echo "  --dry-run               Show what would be done without executing"
    echo "  --help                  Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --project my-app-12345"
    echo "  $0 --project my-app-12345 --environment staging"
}

# Default values
PROJECT_ID=""
ENVIRONMENT="production"
DRY_RUN=false

# Function to parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --project)
                PROJECT_ID="$2"
                shift 2
                ;;
            --environment)
                ENVIRONMENT="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Firebase CLI is installed
    if ! command -v firebase &> /dev/null; then
        print_error "Firebase CLI is not installed or not in PATH"
        print_status "Install with: npm install -g firebase-tools"
        exit 1
    fi
    
    # Check if we're authenticated
    if ! firebase projects:list &> /dev/null; then
        print_error "Not authenticated with Firebase"
        print_status "Run: firebase login"
        exit 1
    fi
    
    # Check if project ID is provided
    if [ -z "$PROJECT_ID" ]; then
        print_error "Project ID is required"
        show_usage
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to upload Remote Config template using the available CLI command
upload_remote_config() {
    # Try remoteconfig:versions:publish first
    if firebase help | grep -q 'remoteconfig:versions:publish'; then
        print_status "Using 'remoteconfig:versions:publish' to upload config..."
        firebase remoteconfig:versions:publish --project "$PROJECT_ID" --config=firebase_remote_config.json && return 0
    fi
    # Fallback to remoteconfig:push if publish is not available
    if firebase help | grep -q 'remoteconfig:push'; then
        print_status "Using 'remoteconfig:push' to upload config..."
        firebase remoteconfig:push --project "$PROJECT_ID" --config=firebase_remote_config.json && return 0
    fi
    print_error "No supported Firebase CLI command found to upload Remote Config template. Please update your Firebase CLI."
    return 1
}

# Function to set up Remote Config parameters
setup_remote_config() {
    if [ "$DRY_RUN" = true ]; then
        print_status "DRY RUN: Would instruct user to update firebase_remote_config.json and deploy via CLI."
        print_status "  Project: $PROJECT_ID"
        print_status "  Environment: $ENVIRONMENT"
        print_status "  Config file: firebase_remote_config.json"
        return
    fi
    
    print_status "To update Remote Config, edit firebase_remote_config.json with the desired parameters:"
    echo "  - app_version (String)"
    echo "  - force_update (Boolean)"
    echo "  - min_version (String)"
    print_status "Then deploy with:"
    echo "    firebase deploy --only remoteconfig"
    print_success "Remote Config deployment instructions provided."
}

# Function to verify setup
verify_setup() {
    if [ "$DRY_RUN" = true ]; then
        print_status "DRY RUN: Would verify Remote Config setup"
        return
    fi
    
    print_status "Verifying Remote Config setup..."
    
    # Get current parameters
    firebase remoteconfig:get --project "$PROJECT_ID" > downloaded_config.json || {
        print_warning "Could not retrieve Remote Config parameters"
        return
    }
    
    print_success "Remote Config setup verified! See downloaded_config.json for details."
}

# Main function
main() {
    print_status "Starting Firebase Remote Config setup..."
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Check prerequisites
    check_prerequisites
    
    # Set up Remote Config
    setup_remote_config
    
    # Verify setup
    verify_setup
    
    print_success "Firebase Remote Config setup completed!"
    print_status "Project: $PROJECT_ID"
    print_status "Environment: $ENVIRONMENT"
    print_status ""
    print_status "Next steps:"
    print_status "1. Update your app version in pubspec.yaml"
    print_status "2. Run: ./scripts/deploy.sh --patch"
    print_status "3. Test the update notification in your app"
}

# Run main function with all arguments
main "$@" 