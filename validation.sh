#!/bin/bash
#######################################Validation Functions for DBMS##########################################################################
validate_name() {
    
    if [ -z "$1" ]; then  
        print_message $RED "✗ Error: Name cannot be empty!"
        return 1
    fi
    
    if [[ "$1" =~ ^[0-9] ]]; then
        print_message $RED "✗ Error: Name cannot start with a number!"
        return 1
    fi
    
    if [[ ! "$1" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
        print_message $RED "✗ Error: Name can only contain letters, numbers, and underscores!"
        echo "       It must start with a letter."
        return 1
    fi
    
    if [ ${#1} -gt 30 ]; then
        print_message $RED "✗ Error: Name is too long! Maximum 30 characters allowed."
        return 1
    fi
    
    if [[ "$1" =~ [[:space:]] ]]; then
        print_message $RED "✗ Error: Database name cannot contain spaces"
        return 1
    fi
    return 0
}
validate_string_data() {
    if [ -z "$1" ]; then  
        print_message $RED "✗ Error: String data cannot be empty!"
        return 1
    fi
    if [[ "$1" =~ ^[0-9] ]]; then
        print_message $RED "✗ Error: Name cannot start with a number!"
        return 1
    fi
    if [[ "$1" =~ [\;\|\$\`\\] ]]; then
        print_message $RED "✗ Error: String data contains dangerous characters!"
        echo "       Characters not allowed: ; | & \$ \` \\"
        return 1
    fi
    
    if [ ${#1} -gt 100 ]; then
        print_message $RED "✗ Error: String data is too long! Maximum 100 characters allowed."
        return 1
    fi
    
    return 0
}
###########################################Function to validate if a database exists######################################################################
validate_database_exists() {
    
    if [ ! -d "$1" ]; then
        print_message $RED "✗ Error: Database '$1' does not exist!"
        return 1
    fi
    
    return 0
}

validate_database_unique() {
    
    if [ -d "$1" ]; then
         print_message $RED "✗ Error: Database '$1' already exists!"
        return 1
    fi
    
    return 0
}
###########################################Function to validate if a table exists######################################################################
validate_table_exists() {
    
    if [ ! -f "${1}.meta" ]; then
       print_message $RED "✗ Error: Table '$1' does not exist!"
        return 1
    fi
    
    return 0
}
validate_table_unique() {
    
    if [ -f "${1}.meta" ]; then
        echo $RED"✗ Error: Table '$1' already exists!"
        return 1
    fi
    
    return 0
}
###########################################Function to validate data type######################################################################

validate_column_value() {
    #1>>> value
    #2>>> datatype
    if [ -z "$1" ]; then
        print_message $RED "✗ Error: Value cannot be empty!"
        return 1
    fi

    case "$2" in
        "Integer"|"integer"|"int"|"INT")
            if [[ "$1" =~ ^-?[0-9]+$ ]]; then
                return 0
            else
                print_message $RED "✗ '$1' is not a valid integer!"
                return 1
            fi
            ;;
        "String"|"string"|"str"|"STR"|"VARCHAR"|"varchar")
           
            if validate_string_data "$1"; then
                return 0 
            else
                return 1  
            fi
            ;;
        "BOOLEAN"|"boolean"|"BOOL"|"bool")
            if [[ "$1" =~ ^(true|false|TRUE|FALSE|0|1)$ ]]; then
                return 0
            else
                print_message $RED "✗ '$1' is not a valid boolean value!"
                return 1
            fi
            ;;
        *)
            print_message $RED "✗ Unknown data type: $2"
            return 1
            ;;
    esac
}
validate_data_type() {
    case "$1" in
        "Integer"|"integer"|"int"|"INT")
            return 0
            ;;
        "String"|"string"|"str"|"STR"|"VARCHAR"|"varchar")
            return 0
            ;;
        "BOOLEAN"|"boolean"|"BOOL"|"bool")
            return 0
            ;;
        *)
            print_message $RED "✗ Invalid data type "
            return 1
            ;;
    esac
}
check_duplicate_column() {
        local new_name="$1"
        for existing_name in "${column_names[@]}"; do
            if [[ "$existing_name" == "$new_name" ]]; then
                return 1 
            fi
        done
        return 0  
    }

###########################################Function to validate integer input######################################################################
validate_integer() {  
    
    if ! [[ "$1" =~ ^-?[0-9]+$ ]]; then
        print_message $RED "✗ Error: '$1' is not a valid integer!"
        return 1
    fi
    
    return 0
}
validate_positive_integer() {

    if ! [[ "$1" =~ ^[1-9][0-9]*$ ]]; then
        print_message $RED "✗ Error: '$1' is not a valid!"
        return 1
    fi

    return 0
}
###########################################Function to validate string input (basic validation)######################################################################
validate_string() {    
    if [ -z "$1" ]; then
        print_message $RED "✗ Error: String cannot be empty!"
        return 1
    fi

    if [ ${#1} -gt 100 ]; then
        print_message $RED "✗ Error: String is too long! Maximum 100 characters allowed."
        return 1
    fi
    
    return 0
}
###########################################Function to get valid input from user######################################################################
get_valid_input() {
    local prompt="$1"
    local validation_function="$2"
    local input
    
    while true; do
        echo -n "$prompt: "
        read input
        
        if [ -z "$validation_function" ]; then
            echo "$input"
            return 0
        fi
        
        if $validation_function "$input"; then
            echo "$input"
            return 0
        fi
        print_message $RED "✗ Error:Please try again."
        echo ""
    done
}


###########################################Function to get valid unique######################################################################

validate_column_unique() {
    #1>>> table name
    #2>>> column name
    if [ -f "${1}.meta" ] && cut -d: -f1 "${1}.meta" | grep -qx "$2"
    then
        print_message $RED "✗ Error: Column '$2' already exists in table '$1'!"
        return 1
    fi
    
    return 0
}

validate_primary_key_unique() {
    #1>>> table name
    #2>>> pk
    #local pk_value="$2"
    
    if [ -f "${1}.data" ] 
    then
        if tail -n +2 "${1}.data" | cut -d: -f1 | grep -qx "$2"
        then
        print_message $RED "✗ Error: Primary key '$2' already exists in table '$1'!"
        return 1
        fi
    fi
    
    return 0
}


###########################################ask yes or no ######################################################################
ask_yes_no() {
    local question="$1"
    while true
    do
        echo -n "$question (Y/n): " 
        read answer
        
        case "$answer" in
            [Yy]|[Yy][Ee][Ss])
                return 0 
                ;;
            [Nn]|[Nn][Oo])
                return 1  
                ;;
               *)
                print_message $RED "✗ Invalid input. Please enter 'y' or 'n'."
                ;;
        esac
    done
}

###########################################Additional helper functions######################################################################

# Function to check if a file is readable and not empty
validate_file_readable() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        print_message $RED "✗ Error: File '$file' does not exist!"
        return 1
    fi
    
    if [ ! -r "$file" ]; then
        print_message $RED "✗ Error: File '$file' is not readable!"
        return 1
    fi
    
    return 0
}

# Function to validate table structure integrity
validate_table_structure() {
    local table_name="$1"
    local meta_file="${table_name}.meta"
    local data_file="${table_name}.data"
    
    # Check if both files exist
    if ! validate_file_readable "$meta_file"; then
        return 1
    fi
    
    if ! validate_file_readable "$data_file"; then
        return 1
    fi
    
    # Count columns in meta file
    local meta_columns=$(wc -l < "$meta_file")
    
    # Count columns in data file header
    local data_columns=$(head -n 1 "$data_file" | tr ':' '\n' | wc -l)
    
    if [ "$meta_columns" -ne "$data_columns" ]; then
        print_message $RED "✗ Error: Table structure mismatch! Meta: $meta_columns columns, Data: $data_columns columns"
        return 1
    fi
    
    return 0
}


# Function to check if directory is writable
validate_directory_writable() {
    local dir="$1"
    
    if [ ! -d "$dir" ]; then
        print_message $RED "✗ Error: Directory '$dir' does not exist!"
        return 1
    fi
    
    if [ ! -w "$dir" ]; then
        print_message $RED "✗ Error: Directory '$dir' is not writable!"
        return 1
    fi
    
    return 0
}

# Function to sanitize input for file operations
sanitize_input() {
    local input="$1"
    
    # Remove potentially dangerous characters
    echo "$input" | sed 's/[^a-zA-Z0-9_-]//g'
}