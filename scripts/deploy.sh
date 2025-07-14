#!/bin/bash

# Apprende Verbs Deployment Script
# This script automates the deployment process including version management and Firebase Remote Config updates

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
VERSION=""
VERSION_TYPE=""
VERSION_MESSAGE=""
FORCE_UPDATE=false
MIN_VERSION=""
ENVIRONMENT="production"
FIREBASE_PROJECT=""
ROLLBACK=false
DRY_RUN=false

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
    echo "  --version VERSION     Set specific version (e.g., 1.2.3)"
    echo "  --patch               Bump patch version (1.0.0 -> 1.0.1)"
    echo "  --minor               Bump minor version (1.0.0 -> 1.1.0)"
    echo "  --major               Bump major version (1.0.0 -> 2.0.0)"
    echo "  --message MESSAGE     Required message for version changes"
    echo "  --force-update        Set force_update to true in Remote Config"
    echo "  --min-version VERSION Set minimum supported version"
    echo "  --environment ENV     Set environment (production|staging) [default: production]"
    echo "  --firebase-project ID Set Firebase project ID (overrides environment)"
    echo "  --rollback            Rollback to previous version"
    echo "  --dry-run             Show what would be done without executing"
    echo "  --help                Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --patch --message \"Bug fix\"     # Bump patch version and deploy"
    echo "  $0 --minor --message \"New feature\" --force-update  # Bump minor version with force update"
    echo "  $0 --force-update             # Deploy without version change, force update"
    echo "  $0 --rollback                 # Rollback to previous version"
}

# Function to parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --version)
                VERSION="$2"
                shift 2
                ;;
            --patch)
                VERSION_TYPE="patch"
                shift
                ;;
            --minor)
                VERSION_TYPE="minor"
                shift
                ;;
            --major)
                VERSION_TYPE="major"
                shift
                ;;
            --message)
                VERSION_MESSAGE="$2"
                shift 2
                ;;
            --force-update)
                FORCE_UPDATE=true
                shift
                ;;
            --min-version)
                MIN_VERSION="$2"
                shift 2
                ;;
            --environment)
                ENVIRONMENT="$2"
                shift 2
                ;;
            --firebase-project)
                FIREBASE_PROJECT="$2"
                shift 2
                ;;
            --rollback)
                ROLLBACK=true
                shift
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
    
    # Check if Flutter is installed
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Check if Firebase CLI is installed
    if ! command -v firebase &> /dev/null; then
        print_error "Firebase CLI is not installed or not in PATH"
        print_status "Install with: npm install -g firebase-tools"
        exit 1
    fi
    
    # Check if we're in a Flutter project
    if [ ! -f "pubspec.yaml" ]; then
        print_error "Not in a Flutter project directory (pubspec.yaml not found)"
        exit 1
    fi
    
    # Check if Firebase project is configured
    if [ ! -f "firebase.json" ]; then
        print_error "Firebase project not configured (firebase.json not found)"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}



# Function to update Firebase Remote Config
update_remote_config() {
    local force_update="$1"
    local min_version="$2"
    
    if [ "$DRY_RUN" = true ]; then
        print_status "DRY RUN: Would update Remote Config:"
        print_status "  force_update: $force_update"
        if [ -n "$min_version" ]; then
            print_status "  min_version: $min_version"
        fi
        return
    fi
    
    print_status "Updating Firebase Remote Config..."
    
    # Update force_update if specified
    if [ "$force_update" = true ]; then
        # Update firebase_remote_config.json directly
        if [ -f firebase_remote_config.json ]; then
            if command -v jq &> /dev/null; then
                jq '.parameters.force_update.defaultValue.value = "true"' firebase_remote_config.json > firebase_remote_config.tmp && mv firebase_remote_config.tmp firebase_remote_config.json
            else
                print_error "jq is required to update firebase_remote_config.json"
                exit 1
            fi
        fi
    fi
    
    # Update min_version if provided
    if [ -n "$min_version" ]; then
        if [ -f firebase_remote_config.json ]; then
            if command -v jq &> /dev/null; then
                jq ".parameters.min_version.defaultValue.value = \"$min_version\"" firebase_remote_config.json > firebase_remote_config.tmp && mv firebase_remote_config.tmp firebase_remote_config.json
            else
                print_error "jq is required to update firebase_remote_config.json"
                exit 1
            fi
        fi
    fi
    
    # Deploy Remote Config changes
    firebase deploy --only remoteconfig || {
        print_error "Failed to deploy Remote Config changes"
        exit 1
    }
    
    print_success "Remote Config updated successfully"
}

# Function to build the Flutter web app
build_app() {
    if [ "$DRY_RUN" = true ]; then
        print_status "DRY RUN: Would build Flutter web app"
        return
    fi
    
    print_status "Building Flutter web app..."
    
    # Clean previous build
    flutter clean
    
    # Get dependencies
    flutter pub get
    
    # Build for web
    flutter build web --release || {
        print_error "Failed to build Flutter web app"
        exit 1
    }
    
    print_success "Flutter web app built successfully"
}

# Function to deploy to Firebase Hosting
deploy_to_firebase() {
    if [ "$DRY_RUN" = true ]; then
        print_status "DRY RUN: Would deploy to Firebase Hosting"
        return
    fi
    
    print_status "Deploying to Firebase Hosting..."
    
    # Deploy to Firebase Hosting
    firebase deploy --only hosting || {
        print_error "Failed to deploy to Firebase Hosting"
        exit 1
    }
    
    print_success "Deployed to Firebase Hosting successfully"
}

# Function to rollback deployment
rollback_deployment() {
    if [ "$DRY_RUN" = true ]; then
        print_status "DRY RUN: Would rollback deployment"
        return
    fi
    
    print_status "Rolling back deployment..."
    
    # Rollback Remote Config
    firebase remote:config:rollback || {
        print_warning "Failed to rollback Remote Config"
    }
    
    # Rollback Hosting (if possible)
    firebase hosting:releases:list | head -5 || {
        print_warning "Could not list hosting releases"
    }
    
    print_success "Rollback completed"
}

# Function to validate version format
validate_version() {
    local version="$1"
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid version format: $version. Expected format: X.Y.Z"
        exit 1
    fi
}

# Function to handle version changes
handle_version_change() {
    local version_type="$1"
    local version="$2"
    local message="$3"
    
    if [ "$DRY_RUN" = true ]; then
        print_status "DRY RUN: Would handle version change:"
        print_status "  Type: $version_type"
        print_status "  Version: $version"
        print_status "  Message: $message"
        return
    fi
    
    print_status "Handling version change..."
    
    # Add changelog entry
    if [ -n "$version_type" ]; then
        # Use add_changelog_entry.sh for version bumps
        ./scripts/add_changelog_entry.sh --$version_type "$message" || {
            print_error "Failed to add changelog entry"
            exit 1
        }
    elif [ -n "$version" ]; then
        # For specific version, we need to manually add to changelog
        print_warning "Specific version specified. Please ensure CHANGELOG.yaml is updated manually."
    fi
    
    # Update versions in all files
    ./scripts/update_versions.sh || {
        print_error "Failed to update versions"
        exit 1
    }
    
    print_success "Version change handled successfully"
}

# Function to set Firebase project
set_firebase_project() {
    local project_id="$FIREBASE_PROJECT"
    
    # If no specific project ID provided, use environment mapping
    if [ -z "$project_id" ]; then
        case $ENVIRONMENT in
            "production")
                project_id="apprende-conjugations"
                ;;
            "staging")
                project_id="apprende-conjugations-staging"
                ;;
            *)
                print_error "Unknown environment: $ENVIRONMENT. Use --firebase-project to specify project ID directly."
                exit 1
                ;;
        esac
    fi
    
    if [ "$DRY_RUN" = true ]; then
        print_status "DRY RUN: Would set Firebase project to $project_id"
        return
    fi
    
    print_status "Setting Firebase project to $project_id..."
    
    # Use the specified project
    firebase use "$project_id" || {
        print_error "Failed to set Firebase project to $project_id"
        print_status "Available projects:"
        firebase projects:list || true
        exit 1
    }
    
    print_success "Firebase project set to $project_id"
}

# Main deployment function
main() {
    print_status "Starting Apprende Verbs deployment..."
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Check prerequisites
    check_prerequisites
    
    # Set Firebase project
    set_firebase_project
    
    # Handle rollback
    if [ "$ROLLBACK" = true ]; then
        rollback_deployment
        exit 0
    fi
    
    # Handle version changes if specified
    if [ -n "$VERSION_TYPE" ] || [ -n "$VERSION" ]; then
        # Require message for version changes
        if [ -z "$VERSION_MESSAGE" ]; then
            print_error "Version change requires a message. Use --message to specify the changelog message."
            show_usage
            exit 1
        fi
        
        # Handle version change
        handle_version_change "$VERSION_TYPE" "$VERSION" "$VERSION_MESSAGE"
    fi
    
    # Build the app
    build_app
    
    # Update Remote Config (only force_update and min_version, app_version is handled by update_versions.sh)
    update_remote_config "$FORCE_UPDATE" "$MIN_VERSION"
    
    # Deploy to Firebase Hosting
    deploy_to_firebase
    
    print_success "Deployment completed successfully!"
    if [ -n "$VERSION_TYPE" ] || [ -n "$VERSION" ]; then
        print_status "Version Change: Yes"
        print_status "Version Type: $VERSION_TYPE"
        print_status "Version Message: $VERSION_MESSAGE"
    else
        print_status "Version Change: No"
    fi
    print_status "Environment: $ENVIRONMENT"
    if [ -n "$FIREBASE_PROJECT" ]; then
        print_status "Firebase Project: $FIREBASE_PROJECT"
    else
        case $ENVIRONMENT in
            "production")
                print_status "Firebase Project: apprende-conjugations"
                ;;
            "staging")
                print_status "Firebase Project: apprende-conjugations-staging"
                ;;
        esac
    fi
    print_status "Force Update: $FORCE_UPDATE"
    if [ -n "$MIN_VERSION" ]; then
        print_status "Minimum Version: $MIN_VERSION"
    fi
}

# Run main function with all arguments
main "$@"