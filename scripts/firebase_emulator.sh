#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
# Ports: Firestore(8080), PubSub(8085), Auth(9099), Storage(9199), UI(14000), Functions(5001)
EMULATOR_PORTS=(8080 8085 9099 9199 14000 5001)
BACKUP_DIR=".firebase/backup"

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

# Help function
show_help() {
    echo "Usage: ./scripts/firebase_emulator.sh [OPTIONS]"
    echo ""
    echo "Starts the Firebase Emulator Suite with data persistence."
    echo ""
    echo "Options:"
    echo "  --clean    Start fresh (clear existing data) and do not import backup"
    echo "  --help     Show this help message"
    echo ""
}

# Function to check if Java is installed
check_java() {
    if ! command -v java &> /dev/null; then
        print_error "Java is not installed or not in PATH."
        print_error "Firebase Emulators require Java to run."
        print_error "Please install Java and try again."
        exit 1
    fi
}

# Function to check if a port is in use
is_port_in_use() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0  # Port is in use
    else
        return 1  # Port is free
    fi
}

# Function to get process ID using a port
get_pid_by_port() {
    local port=$1
    lsof -ti :$port 2>/dev/null
}

# Function to stop Firebase emulators
stop_firebase_emulators() {
    print_status "Stopping existing Firebase emulators..."
    
    # Try to stop using firebase emulators:stop
    if firebase emulators:stop >/dev/null 2>&1; then
        print_success "Firebase emulators stopped successfully"
        return 0
    fi
    
    local killed_any=false
    
    for port in "${EMULATOR_PORTS[@]}"; do
        if is_port_in_use $port; then
            local pid=$(get_pid_by_port $port)
            if [ ! -z "$pid" ]; then
                print_warning "Killing process $pid using port $port"
                kill -TERM $pid 2>/dev/null
                sleep 1
                # Force kill if still running
                if kill -0 $pid 2>/dev/null; then
                    print_warning "Force killing process $pid"
                    kill -KILL $pid 2>/dev/null
                fi
                killed_any=true
            fi
        fi
    done
    
    if [ "$killed_any" = true ]; then
        print_success "Processes using emulator ports have been terminated"
        sleep 2  # Give time for ports to be released
    fi
}

# Function to check if ports are available
check_ports() {
    local unavailable_ports=()
    
    for port in "${EMULATOR_PORTS[@]}"; do
        if is_port_in_use $port; then
            unavailable_ports+=($port)
        fi
    done
    
    if [ ${#unavailable_ports[@]} -gt 0 ]; then
        print_warning "The following ports are in use: ${unavailable_ports[*]}"
        return 1
    fi
    
    return 0
}

# Main execution
main() {
    local CLEAN_START=false

    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --clean) CLEAN_START=true ;;
            --help) show_help; exit 0 ;;
            *) print_error "Unknown parameter: $1"; show_help; exit 1 ;;
        esac
        shift
    done

    print_status "Starting Firebase emulator setup..."
    
    # Check prerequisites
    check_java
    
    # Check if firebase CLI is installed
    if ! command -v firebase &> /dev/null; then
        print_error "Firebase CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if we're in a Firebase project
    if [ ! -f "firebase.json" ]; then
        print_error "firebase.json not found. Please run this script from the project root."
        exit 1
    fi
    
    # Check if ports are available
    if ! check_ports; then
        print_status "Attempting to stop existing emulators..."
        stop_firebase_emulators
        
        # Check again after stopping
        if ! check_ports; then
            print_error "Some ports are still unavailable after stopping emulators."
            print_error "Please manually stop the processes using these ports and try again."
            exit 1
        fi
    fi
    
    print_success "All required ports are available"
    
    # Handle backup directory
    if [ "$CLEAN_START" = true ]; then
        print_warning "Clean start requested. Removing existing backup..."
        rm -rf "$BACKUP_DIR"
    fi

    if [ ! -d "$BACKUP_DIR" ]; then
        print_status "Creating backup directory..."
        mkdir -p "$BACKUP_DIR"
    fi
    
    print_status "Starting Firebase emulators..."
    print_status "Emulator UI will be available at: http://localhost:14000"
    
    # Start the emulators
    if [ "$CLEAN_START" = true ]; then
        # Don't import, but export on exit
        firebase emulators:start --export-on-exit "$BACKUP_DIR"
    else
        # Import if exists, export on exit
        if [ -z "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
             print_status "No existing backup found. Starting fresh..."
             firebase emulators:start --export-on-exit "$BACKUP_DIR"
        else
             print_status "Importing data from $BACKUP_DIR..."
             firebase emulators:start --import "$BACKUP_DIR" --export-on-exit "$BACKUP_DIR"
        fi
    fi
}

# Run main function
main "$@"