#!/bin/bash
# variables
DBMS_HOME="$HOME/dbms_data"  # Main folder for all databases
export DBMS_HOME="$HOME/dbms_data"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  #want the pwd of script
# Source other script files
source "$SCRIPT_DIR/validation.sh"
source "$SCRIPT_DIR/main_menu.sh"
source "$SCRIPT_DIR/database_menu.sh"
source "$SCRIPT_DIR/table_operations.sh"
source "$SCRIPT_DIR/data_operations.sh"
# Color 
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

initialize_dbms() {
    echo "...Initializing Database Management System..."
    
   if [ ! -d "$DBMS_HOME" ]; then
        echo "First time running Simple DBMS!"
        echo "Creating database system folder at: $DBMS_HOME"
        mkdir -p "$DBMS_HOME"
        echo $GREEN"Database system initialized successfully!"
        echo ""
    else
        echo "Database system found at: $DBMS_HOME"
        echo "Loading existing databases..."
        echo ""
    fi
    
    # Change to the database directory
    cd "$DBMS_HOME"
}
    
main() {
    echo "Starting Database Management System..."
    
    initialize_dbms
    
while true 
do
    show_main_menu
done
}

# Start the program
main "$@"