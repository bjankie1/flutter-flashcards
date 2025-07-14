#!/bin/bash

# purge_merged_branches.sh
# Script to safely purge merged branches from local Git repository
# 
# Usage: ./scripts/purge_merged_branches.sh [options]
# Options:
#   -d, --dry-run    Show what would be deleted without actually deleting
#   -f, --force      Force delete unmerged branches as well
#   -h, --help       Show this help message

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DRY_RUN=false
FORCE_DELETE=false
TARGET_BRANCH="main"

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

# Function to show help
show_help() {
    cat << EOF
purge_merged_branches.sh - Safely purge merged branches from local Git repository

Usage: $0 [options]

Options:
    -d, --dry-run    Show what would be deleted without actually deleting
    -f, --force      Force delete unmerged branches as well (use with caution!)
    -b, --branch     Specify target branch to check against (default: main)
    -h, --help       Show this help message

Examples:
    $0                    # Delete merged branches only
    $0 --dry-run         # Show what would be deleted
    $0 --force           # Delete both merged and unmerged branches
    $0 --branch develop  # Check against develop branch instead of main

Safety Features:
    - Never deletes the current branch
    - Never deletes main/master branches
    - Shows preview before deletion (unless --force is used)
    - Validates Git repository before proceeding
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -f|--force)
            FORCE_DELETE=true
            shift
            ;;
        -b|--branch)
            TARGET_BRANCH="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Function to validate Git repository
validate_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not a Git repository. Please run this script from a Git repository root."
        exit 1
    fi
}

# Function to check if target branch exists
check_target_branch() {
    if ! git show-ref --verify --quiet refs/heads/$TARGET_BRANCH; then
        print_error "Target branch '$TARGET_BRANCH' does not exist."
        print_info "Available branches:"
        git branch --format='%(refname:short)'
        exit 1
    fi
}

# Function to get current branch
get_current_branch() {
    git branch --show-current
}

# Function to get merged branches
get_merged_branches() {
    git branch --merged $TARGET_BRANCH --format='%(refname:short)'
}

# Function to get unmerged branches
get_unmerged_branches() {
    git branch --no-merged $TARGET_BRANCH --format='%(refname:short)'
}

# Function to filter out protected branches
filter_protected_branches() {
    local branches="$1"
    local current_branch=$(get_current_branch)
    
    echo "$branches" | grep -v -E "^(main|master|$current_branch)$" | grep -v '^$'
}

# Function to delete branches
delete_branches() {
    local branches="$1"
    local force_flag="$2"
    
    if [[ -z "$branches" ]]; then
        print_info "No branches to delete."
        return
    fi
    
    echo "$branches" | while read -r branch; do
        if [[ -n "$branch" ]]; then
            if [[ "$DRY_RUN" == true ]]; then
                print_info "Would delete: $branch"
            else
                print_info "Deleting: $branch"
                if git branch $force_flag "$branch" 2>/dev/null; then
                    print_success "Deleted: $branch"
                else
                    print_error "Failed to delete: $branch"
                fi
            fi
        fi
    done
}

# Function to prune remote-tracking branches
prune_remote_branches() {
    print_info "Pruning remote-tracking branches..."
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "Would prune remote-tracking branches (dry run)"
        git remote prune --dry-run origin 2>/dev/null || true
    else
        git remote prune origin 2>/dev/null || true
        print_success "Remote-tracking branches pruned"
    fi
}

# Main execution
main() {
    print_info "Starting branch cleanup process..."
    print_info "Target branch: $TARGET_BRANCH"
    print_info "Current branch: $(get_current_branch)"
    print_info "Dry run: $DRY_RUN"
    print_info "Force delete: $FORCE_DELETE"
    echo
    
    # Validate repository
    validate_git_repo
    
    # Check target branch
    check_target_branch
    
    # Get current branch
    local current_branch=$(get_current_branch)
    
    # Safety check - don't run if on a branch that might be deleted
    if [[ "$current_branch" != "main" && "$current_branch" != "master" ]]; then
        print_warning "You are currently on branch '$current_branch'"
        print_warning "This script will not delete the current branch, but be careful!"
        echo
    fi
    
    # Get merged branches
    print_info "Finding merged branches..."
    local merged_branches=$(get_merged_branches)
    local merged_to_delete=$(filter_protected_branches "$merged_branches")
    
    if [[ -n "$merged_to_delete" ]]; then
        print_info "Merged branches to delete:"
        echo "$merged_to_delete" | sed 's/^/  - /'
        echo
    else
        print_info "No merged branches to delete."
        echo
    fi
    
    # Get unmerged branches (if force delete is enabled)
    local unmerged_to_delete=""
    if [[ "$FORCE_DELETE" == true ]]; then
        print_warning "Force delete enabled - will also delete unmerged branches!"
        local unmerged_branches=$(get_unmerged_branches)
        unmerged_to_delete=$(filter_protected_branches "$unmerged_branches")
        
        if [[ -n "$unmerged_to_delete" ]]; then
            print_warning "Unmerged branches to delete:"
            echo "$unmerged_to_delete" | sed 's/^/  - /'
            echo
        else
            print_info "No unmerged branches to delete."
            echo
        fi
    fi
    
    # Confirm deletion (unless dry run or force)
    if [[ "$DRY_RUN" == false && "$FORCE_DELETE" == false ]]; then
        local total_branches=$(echo "$merged_to_delete" | wc -l | tr -d ' ')
        if [[ "$total_branches" -gt 0 ]]; then
            print_warning "About to delete $total_branches merged branch(es)."
            read -p "Continue? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_info "Operation cancelled."
                exit 0
            fi
        fi
    fi
    
    # Delete merged branches
    if [[ -n "$merged_to_delete" ]]; then
        print_info "Deleting merged branches..."
        delete_branches "$merged_to_delete" "-d"
        echo
    fi
    
    # Delete unmerged branches (if force delete is enabled)
    if [[ "$FORCE_DELETE" == true && -n "$unmerged_to_delete" ]]; then
        print_warning "Deleting unmerged branches..."
        delete_branches "$unmerged_to_delete" "-D"
        echo
    fi
    
    # Prune remote-tracking branches
    prune_remote_branches
    echo
    
    # Summary
    print_success "Branch cleanup completed!"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "This was a dry run. No branches were actually deleted."
        print_info "Run without --dry-run to actually delete the branches."
    fi
    
    # Show remaining branches
    print_info "Remaining local branches:"
    git branch --format='%(refname:short)' | sed 's/^/  /'
}

# Run main function
main "$@" 