#!/bin/bash
#######################################Validation Functions for DBMS##########################################################################
validate_name() {
    local name="$1"  #not global just loacal
    
    # Check if name is empty
    if [ -z "$name" ]; then    #are name is empty?
        print_message $RED "❌ Error: Name cannot be empty!"
        return 1
    fi
    
    # Check if name starts with a number
    if [[ "$name" =~ ^[0-9] ]]; then
        print_message $RED "❌ Error: Name cannot start with a number!"
        return 1
    fi
    
    # Check for special characters and spaces (only letters, numbers, and underscores allowed)
    if [[ ! "$name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
        print_message $RED "❌ Error: Name can only contain letters, numbers, and underscores!"
        echo "       It must start with a letter."
        return 1
    fi
    
    # Check length 
    if [ ${#name} -gt 30 ]; then
        print_message $RED "❌ Error: Name is too long! Maximum 30 characters allowed."
        return 1
    fi
    
    if [[ "$name" =~ [[:space:]] ]]; then
        print_message $RED "❌ Error: Database name cannot contain spaces"
        return 1
    fi
    return 0
}
###########################################Function to validate if a database exists######################################################################
validate_database_exists() {
    local db_name="$1"
    
    if [ ! -d "$db_name" ]; then
        print_message $RED "❌ Error: Database '$db_name' does not exist!"
        return 1
    fi
    
    return 0
}

validate_database_unique() {
    local db_name="$1"
    
    if [ -d "$db_name" ]; then
         print_message $RED "✗Error: Database '$db_name' already exists!"
        return 1
    fi
    
    return 0
}
###########################################Function to validate if a table exists######################################################################
validate_table_exists() {
    local table_name="$1"
    
    if [ ! -f "${table_name}.meta" ]; then
       print_message $RED "❌ Error: Table '$table_name' does not exist!"
        return 1
    fi
    
    return 0
}
validate_table_unique() {
    local table_name="$1"
    
    if [ -f "${table_name}.meta" ]; then
        echo $RED"❌Error: Table '$table_name' already exists!"
        return 1
    fi
    
    return 0
}
###########################################Function to validate data type######################################################################
validate_data_type() {
    local data_type="$1"
    
    if [ "$data_type" != "Integer" ] && [ "$data_type" != "String" ]; then
        print_message $RED "❌ Error: Data type must be 'Integer' or 'String'!"
        return 1
    fi
    
    return 0
}
###########################################Function to validate integer input######################################################################
validate_integer() {
    local value="$1"
    
    if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
        print_message $RED "❌ Error: '$value' is not a valid integer!"
        return 1
    fi
    
    return 0
}
validate_positive_integer() {
    local value="$1"

    if ! [[ "$value" =~ ^[1-9][0-9]*$ ]]; then
        print_message $RED "❌ Error: '$value' is not a positive integer!"
        return 1
    fi

    return 0
}
###########################################Function to validate string input (basic validation)######################################################################
validate_string() {
    local value="$1"
    
    # Check if string is empty
    if [ -z "$value" ]; then
        print_message $RED "❌ Error: String cannot be empty!"
        return 1
    fi
    
    # Check for reasonable length
    if [ ${#value} -gt 100 ]; then
        print_message $RED "❌ Error: String is too long! Maximum 100 characters allowed."
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
        
        # If no validation function provided, just return the input
        if [ -z "$validation_function" ]; then
            echo "$input"
            return 0
        fi
        
        # Call the validation function
        if $validation_function "$input"; then
            echo "$input"
            return 0
        fi
        print_message $RED "Please try again."
        echo ""
    done
}
###########################################Function to pause and wait for user input######################################################################
pause_for_user() {
    echo ""
    echo -n "Press Enter to continue..."
    read
    echo ""
}

###########################################Function to get valid unique######################################################################

validate_column_unique() {
    local table_name="$1"
    local column_name="$2"
    
    if [ -f "${table_name}.meta" ] && grep -q "^$column_name:" "${table_name}.meta"; then
        print_message $RED "❌ Error: Column '$column_name' already exists in table '$table_name'!"
        return 1
    fi
    
    return 0
}

validate_primary_key_unique() {
    local table_name="$1"
    local pk_value="$2"
    
    if [ -f "${table_name}.data" ] && grep -q "^$pk_value:" "${table_name}.data"; then
        print_message $RED "❌ Error: Primary key '$pk_value' already exists in table '$table_name'!"
        return 1
    fi
    
    return 0
}