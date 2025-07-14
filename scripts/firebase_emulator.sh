#!/bin/bash

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
    
    # If firebase emulators:stop fails, try to kill processes by port
    local ports=(8080 8085 9099 9199 14000 5000 5002)
    local killed_any=false
    
    for port in "${ports[@]}"; do
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
    local ports=(8080 8085 9099 9199 14000)
    local unavailable_ports=()
    
    for port in "${ports[@]}"; do
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
    print_status "Starting Firebase emulator setup..."
    
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
    
    # Create backup directory if it doesn't exist
    if [ ! -d ".firebase/backup" ]; then
        print_status "Creating backup directory..."
        mkdir -p .firebase/backup
    fi
    
    print_status "Starting Firebase emulators..."
    print_status "Emulator UI will be available at: http://localhost:14000"
    
    # Start the emulators
    firebase emulators:start --import .firebase/backup --export-on-exit .firebase/backup
}

# Run main function
main "$@"