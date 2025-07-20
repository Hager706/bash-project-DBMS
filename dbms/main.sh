#!/bin/bash
# variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  #want the pwd of script
DBMS_HOME="$SCRIPT_DIR/dbms_data"  # Main folder for all databases
export DBMS_HOME="$SCRIPT_DIR/dbms_data"
# Source other script files
source "$SCRIPT_DIR/validation.sh"
source "$SCRIPT_DIR/menu.sh"
# source "$SCRIPT_DIR/database_menu.sh"
# source "$SCRIPT_DIR/table_operations.sh"
# source "$SCRIPT_DIR/data_operations.sh"
# Color 
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

initialize_dbms() {
print_message $GREEN "╔══════════════════════════════╗"
print_message $GREEN "║     DBMS Initialization      ║"
print_message $GREEN "╚══════════════════════════════╝"    
   if [ ! -d "$DBMS_HOME" ]; then
        echo "First time running Simple DBMS ;)"
        print_message $GREEN "✓ Created main databases directory: $DBMS_HOME"
        mkdir -p "$DBMS_HOME"
        print_message $GREEN "✓ Database system initialized successfully!"
        echo ""
    else
        print_message $GREEN "✓ DBMS already initialized"
        print_message $GREEN "✓Loading existing databases..."
        echo ""
    fi
    
    # Change to the database directory
    cd "$DBMS_HOME"
}
    
main() {
  #  print_message $GREEN "✓ Starting Database Management System..."
    
    initialize_dbms
    
    show_main_menu

}

# Start the program
main "$@"