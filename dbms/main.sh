#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  #want the pwd of script
DBMS_HOME="$SCRIPT_DIR/dbms_data"  # Main folder for all databases
export DBMS_HOME

source "$SCRIPT_DIR/validation.sh"
source "$SCRIPT_DIR/menu.sh"
source "$SCRIPT_DIR/DBmenu.sh"
source "$SCRIPT_DIR/DBmenu2.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

initialize_dbms() {



   if [ ! -d "$DBMS_HOME" ]; then
        echo "First time running Simple DBMS ;)"
        print_message $GREEN "✓ Created main databases directory: $DBMS_DIR"
        mkdir -p "$DBMS_HOME"
        print_message $GREEN "✓ Database system initialized successfully!"
        echo ""
    else
        print_message $GREEN "✓ DBMS already initialized"
        print_message $GREEN "✓ Loading existing databases..."
        echo ""
    fi
    
    cd "$DBMS_HOME"
}

main() {
    
# chmod +x main.sh
# chmod +x validation.sh
# chmod +x main_menu.sh
# chmod +x database_menu.sh
    echo
    initialize_dbms
    
    show_main_menu

}

# Start the program
main "$@"
