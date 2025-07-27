select_from_table() {
print_message $BLUE "█▓▒░ SELECT DATA FROM TABLE $1 ░▒▓█"
local found=0
local count=1
declare -a table_names=()
declare -a columns
if ! cd "$DBMS_HOME/$1" 2>/dev/null; then
        print_message $RED "✗ Error: Cannot access database directory"
        return 1
fi
for file in *.meta
do
        if [ -f "$file" ]
        then
           if [ $found -eq 0 ]; then
            echo ""
            print_message $GREEN "Available tables:"
            #make this because the Available tables: print with every table found
            fi
            found=1
            table_name="${file%.meta}"
            table_names+=("$table_name")
            print_message $GREEN "$count. $table_name"
            ((count++))
        fi
       
done

    if [ $found -eq 0 ]
    then
        echo ""
        print_message $RED "✗ Error: No tables found "
        echo " "
        if ask_yes_no "Do you want to create a table?" 
        then
            create_table "$1"
            echo ""
        fi
        return
    fi
    echo 

while true
do 
        echo -n "Enter the number of the table to select from:(or 'back' to return): "
        read number
        if [ "$number" = "back" ]; then
            return
        fi
        if ! validate_positive_integer "$number"
        then
            echo ""
            continue
        fi 

        if [ "$number" -lt 1 ] || [ "$number" -gt $((count - 1)) ]
        then 
           print_message $RED "✗ Error:Invalid table number"
           echo ""
           continue
        fi 
        break
    done

    table_name="${table_names[$((number-1))]}"
while true
do
echo
print_message $BLUE "╭━━━━━━━━━━━━[$table_name]━━━━━━━━━━━━━━╮"
print_message $BLUE "┃    Select Options for Table         ┃"
print_message $BLUE "╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯"
echo
PS3="Please select an option (1-5): "
echo
echo
    select choice in "View all records" "View specific record" "View specific columns" "Back to database Menu" "Exit" 
    do
            case $choice in
                "View all records") 
                    Viewall "$table_name"
                    break
                    ;;
                "View specific record")  
                    ViewspecRec "$table_name"
                    break
                    ;;
                "View specific columns") 
                    ViewspecCol "$table_name"
                    break
                    ;;
                "Back to database Menu") 
			       echo
                    DBmenu "$1"
                    ;;
                "Exit")
              print_message $GREEN "Goodbye! Thank you for using our DBMS."
               exit 0
                 ;;
                *)
                    print_message $RED "✗ Error:Invalid option. Please try again."
                    break
                    ;;
            esac
        done
    done
# Show available tables √
# Let user select a table √
# Provide options:√
#    View all records √
#    View specific record by primary key√
#    View specific columns only√
# Display data in formatted table√

# === employees table ===
# ID    | Name      | Salary
# ------|-----------|-------
# 1     | John Doe  | 50000
# 2     | Jane Smith| 60000
}
Viewall() {
local table="$1"
local data_file="${table}.data"
local record_count=$(($(wc -l < "$data_file") - 1))

    if [ ! -f "$data_file" ]; then
        print_message $RED "✗ Error:Data file for table '$table' not found!"
        return 1
    fi
    if [ "$record_count" -eq 0 ]; then
        print_message $YELLOW "⚠️ Table '$table_name' is empty"
        echo
        if ask_yes_no "Would you like to add a record to this table?"; then
            insert_into_table "$(basename "$PWD")"
        fi
        return
    fi
    IFS= read -r header < "$data_file"  #id:name:age
    IFS=':' read -ra columns <<< "$header"
    # columns[0]="id"
    # columns[1]="name"
    # columns[2]="age"
    # Print column headers

    printf "|"
    for col in "${columns[@]}"; do
        printf " %-10s |" "$col"
    done
    echo
 
    # Print separator - FIX: Use -- to prevent printf from interpreting dashes as options
    printf "|"
    for _ in "${columns[@]}"; do
        printf -- "------------|"
    done
    echo
 
    tail -n +2 "$data_file" | while IFS=':' read -ra fields; do
        printf "|"
        for field in "${fields[@]}"; do
            printf " %-10s |" "$field"
        done
        echo
    done
 
    echo
}
ViewspecRec() {
local table="$1"
local data_file="${table}.data"
local meta_file="${table}.meta"
local primary_key="${columns[0]}"
local record_count=$(tail -n +2 "$data_file" | wc -l)

    if [ ! -f "$data_file" ] || [ ! -f "$meta_file" ]
    then
        print_message $RED "✗ Error: Table files not found!"
        return 1
    fi
    
    if [ ! -s "$data_file" ]; then
        print_message $YELLOW "Table '$table' is empty"
        return
    fi
    
    IFS= read -r header < "$data_file"
    IFS=':' read -ra columns <<< "$header"
    

    
    if [ "$record_count" -eq 0 ]; then
        print_message $YELLOW "Table '$table' has no data records (only header)"
        return
    fi
    
    print_message $GREEN "Available $primary_key values in table '$table':"
    echo "+----------------------+"
    printf "| %-20s |\n" "$primary_key"
    echo "+----------------------+"
    
    tail -n +2 "$data_file" | while IFS=':' read -r line; do
        pk_value=$(echo "$line" | cut -d':' -f1)
        printf "| %-20s |\n" "$pk_value"
    done
    
    echo "+----------------------+"
    echo
    
    while true; do
        echo -n "Enter the $primary_key value of the record to view (or 'back' to return): "
        read input_pk_value
        
        if [ "$input_pk_value" = "back" ]; then
            return
        fi
        
        if [ -z "$input_pk_value" ]; then
            print_message $RED "✗ Error: Please enter a valid $primary_key value"
            continue
        fi
        
        local found_record=$(tail -n +2 "$data_file" | grep "^${input_pk_value}:")
        
        if [ -z "$found_record" ]; then
            print_message $RED "✗ No record found with $primary_key = '$input_pk_value'"
            continue
        fi
        
        echo
        print_message $GREEN "Record found:"
        echo
        
        printf "|"
        for col in "${columns[@]}"; do
            printf " %-15.15s |" "$col"
        done
        echo
        
        printf "|"
        for _ in "${columns[@]}"; do
            printf -- "-----------------|"
        done
        echo
        
        IFS=':' read -ra record_fields <<< "$found_record"
        printf "|"
        for field in "${record_fields[@]}"; do
            # Safe printf that handles -- and other special characters
            printf " %-15.15s |" "${field:-}"
        done
        echo
        echo
        
        break
    done
}

ViewspecCol() {
    local table="$1"
    local data_file="${table}.data"
    
    if [ ! -f "$data_file" ]; then
        print_message $RED "✗ Error: Data file for table '$table' not found!"
        return 1
    fi
    
    IFS= read -r header < "$data_file"
    IFS=':' read -ra columns <<< "$header"
    
    print_message $GREEN "Available columns:"
    echo ""
    for i in "${!columns[@]}"; do
        echo "$((i+1)). ${columns[$i]}"
    done
    
    echo ""
    while true; do
        echo -n "Enter column numbers separated by spaces (e.g., '1 3 4') or 'back' to return: "
        read -a selected_numbers
        
        if [ "${selected_numbers[0]}" = "back" ]; then
            return
        fi
        
        if [ ${#selected_numbers[@]} -eq 0 ]; then
            print_message $RED "✗ Error:Please enter at least one column number"
            continue
        fi
        
        local valid=1
        declare -a selected_indices=()
        
        for num in "${selected_numbers[@]}"; do
            if ! validate_positive_integer "$num"; then
                print_message $RED "✗ Error:Invalid number: $num"
                valid=0
                break
            fi
            
            if [ "$num" -lt 1 ] || [ "$num" -gt ${#columns[@]} ]; then
                print_message $RED "✗ Error:Column number $num is out of range (1-${#columns[@]})"
                valid=0
                break
            fi
            
            selected_indices+=($((num-1)))
        done
        
        if [ $valid -eq 0 ]; then
            continue
        fi
        
        echo ""
        print_message $BLUE "=== Selected Columns from $table table ==="
        echo ""
        
        printf "|"
        for index in "${selected_indices[@]}"; do
            printf " %-15s |" "${columns[$index]}"
        done
        echo
        
        printf "|"
        for _ in "${selected_indices[@]}"; do
            printf -- "-----------------|"
        done
        echo
        
        tail -n +2 "$data_file" | while IFS=':' read -ra fields; do
            printf "|"
            for index in "${selected_indices[@]}"; do
                printf " %-15s |" "${fields[$index]}"
            done
            echo
        done
        
        echo ""
        break
    done
}




delete_from_table() {
    print_message $BLUE "█▓▒░ DELETE DATA FROM TABLE $1 ░▒▓█"
    local found=0
    local count=1
    declare -a table_names=()
    declare -a columns
    
    if ! cd "$DBMS_HOME/$1" 2>/dev/null; then
        print_message $RED "✗ Error: Cannot access database directory"
        return 1
    fi
    
    for file in *.meta; do
        if [ -f "$file" ]; then
            if [ $found -eq 0 ]; then
                echo ""
                print_message $GREEN "Available tables:"
            fi
            found=1
            table_name="${file%.meta}"
            table_names+=("$table_name")
            print_message $GREEN "$count. $table_name"
            ((count++))
        fi
    done

    if [ $found -eq 0 ]; then
        echo ""
        print_message $RED "✗ Error: No tables found"
        echo ""
        if ask_yes_no "Do you want to create a table?"; then
            create_table "$1"
            echo ""
            return
        fi
        return  # Fixed: Don't call DBmenu here, just return
    fi
    echo 

    while true; do 
        echo -n "Enter the number of the table to delete from (or 'back' to return): "
        read number
        if [ "$number" = "back" ]; then
            return
        fi
        if ! validate_positive_integer "$number"; then
            print_message $RED "✗ Error: Please enter a valid number"
            echo ""
            continue
        fi 

        if [ "$number" -lt 1 ] || [ "$number" -gt $((count - 1)) ]; then 
            print_message $RED "✗ Error: Invalid table number"
            echo ""
            continue
        fi 
        break
    done

    table_name="${table_names[$((number-1))]}"
    
    while true; do
        echo
        print_message $BLUE "╭━━━━━━━━━━━━[$table_name]━━━━━━━━━━━━━━╮"
        print_message $BLUE "┃    Delete Options for Table         ┃"
        print_message $BLUE "╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯"
        echo
        
        PS3="Please select an option (1-3): "
        select choice in "Delete specific record by primary key" "Delete all records" "Back to database Menu" "Exit"; do
            case $choice in
                "Delete specific record by primary key") 
                    DeletespecRec "$table_name"
                    break
                    ;;
                "Delete all records")  
                    DeleteAll "$table_name"
                    break
                    ;;
                "Back to database Menu") 
                    echo
                    return  # Fixed: Return instead of calling DBmenu
                    ;;
                "Exit")
                print_message $GREEN "Goodbye! Thank you for using our DBMS."
                exit 0
                 ;;
                *)
                    print_message $RED "✗ Error: Invalid option. Please try again."
                    break
                    ;;
            esac
        done
    done
}

DeletespecRec() {
    local table="$1"
    local data_file="${table}.data"
    local meta_file="${table}.meta"
    
    if [ ! -f "$data_file" ] || [ ! -f "$meta_file" ]; then
        print_message $RED "✗ Error: Table files not found!"
        return 1
    fi

    # Check if table has data (more than just header)
    local record_count=$(($(wc -l < "$data_file") - 1))
    if [ "$record_count" -eq 0 ]; then
        print_message $YELLOW "⚠️ Table '$table' is empty - nothing to delete"
        return
    fi
    
    # Show current table data
    echo
    print_message $BLUE "Current table data:"
    Viewall "$table"
    echo
    
    # Get primary key name from header
    local primary_key=$(head -n 1 "$data_file" | cut -d':' -f1)
    
    while true; do
        echo -n "Enter the $primary_key value of the record to delete (or 'back' to return): "
        read pk_value
        
        if [ "$pk_value" = "back" ]; then
            return
        fi
        
        if [ -z "$pk_value" ]; then
            print_message $RED "✗ Error: Please enter a valid $primary_key value"
            continue
        fi
        
        # Search for the record (Fixed: moved inside the loop)
        local found_record=$(tail -n +2 "$data_file" | grep "^${pk_value}:")
        
        if [ -z "$found_record" ]; then
            print_message $RED "✗ No record found with $primary_key = '$pk_value'"
            continue
        fi

        # Display the record to be deleted
        echo
        print_message $YELLOW "Record to be deleted:"
        
        IFS= read -r header < "$data_file"
        IFS=':' read -ra columns <<< "$header"
        IFS=':' read -ra record_fields <<< "$found_record"
        
        # Print header with safe printf
        printf "|"
        for col in "${columns[@]}"; do
            printf " %-15.15s |" "${col:-}"
        done
        echo
        
        # Print separator
        printf "|"
        for _ in "${columns[@]}"; do
            printf -- "-----------------|"
        done
        echo
        
        # Print record data with safe printf
        printf "|"
        for field in "${record_fields[@]}"; do
            printf " %-15.15s |" "${field:-}"
        done
        echo
        echo
        
        if ask_yes_no "Are you sure you want to delete this record? This action cannot be undone"; then
            # Create a temporary file for safe deletion
            local temp_file=$(mktemp)
            
            # Copy header
            head -n 1 "$data_file" > "$temp_file"
            
            # Copy all records except the one to delete
            tail -n +2 "$data_file" | grep -v "^${pk_value}:" >> "$temp_file"
            
            # Replace original file
            if mv "$temp_file" "$data_file"; then
                echo
                print_message $GREEN "✓ Record with $primary_key = '$pk_value' deleted successfully!"
                echo
                print_message $BLUE "Remaining records:"
                Viewall "$table"
            else
                print_message $RED "✗ Error: Failed to delete record"
                rm -f "$temp_file"  # Clean up temp file
            fi
        else
            print_message $YELLOW "Deletion cancelled"
            echo
        fi
        
        break
    done
}

DeleteAll() {
    local table="$1"
    local data_file="${table}.data"
    
    if [ ! -f "$data_file" ]; then
        print_message $RED "✗ Error: Data file for table '$table' not found!"
        return 1
    fi
    
    # Check if table has data (more than just header)
    local record_count=$(($(wc -l < "$data_file") - 1))
    
    if [ $record_count -eq 0 ]; then
        print_message $YELLOW "⚠️ Table '$table' is already empty"
        return 0
    fi
    
    # Show current table data
    echo
    print_message $BLUE "Current table data:"
    Viewall "$table"
    echo
    
    print_message $YELLOW "⚠️ This will delete ALL $record_count records from table '$table'"
    print_message $YELLOW "⚠️ The table structure will be preserved (columns will remain)"
    echo
    
    if ask_yes_no "Are you sure you want to delete ALL records? This action cannot be undone"; then
        # Keep only the header (first line)
        local temp_file=$(mktemp)
        head -n 1 "$data_file" > "$temp_file"
        
        if mv "$temp_file" "$data_file"; then
            echo
            print_message $GREEN "✓ All records deleted successfully from table '$table'"
            print_message $BLUE "Table structure preserved. You can add new records anytime."
            echo
            
            # Show the empty table (just header)
            print_message $BLUE "Table now contains:"
            Viewall "$table"
        else
            print_message $RED "✗ Error: Failed to delete records"
            rm -f "$temp_file"  # Clean up temp file
        fi
    else
        print_message $BLUE "Deletion cancelled"
        echo
    fi
}

update_table() {
    local db_name="$1"
    print_message $BLUE "=== Update Records in Table ==="
    echo
    
    meta_files=($(ls "$DBMS_HOME/$db_name"/*.meta 2>/dev/null))
    
    if [ ${#meta_files[@]} -eq 0 ]; then
        print_message $YELLOW "No tables found in database '$db_name'"
        echo
        return
    fi
    
    print_message $GREEN "Available tables:"
    for (( i = 0; i < ${#meta_files[@]}; i++ )); do
        table_name=$(basename "${meta_files[$i]}" .meta)
        print_message $GREEN "$((i+1)). $table_name"
    done
    echo
    
    while true; do
        echo -n "Enter table number (or 'back' to return): "
        read table_num
        
        if [ "$table_num" = "back" ]; then
            return
        fi
        
        if validate_positive_integer "$table_num"; then
            table_index=$((table_num - 1))
            if [ "$table_index" -ge 0 ] && [ "$table_index" -lt ${#meta_files[@]} ]; then
                selected_table=$(basename "${meta_files[$table_index]}" .meta)
                break
            else
                print_message $RED "❌ Invalid table number!"
                echo
            fi
        else
            print_message $RED "❌ Please enter a valid number."
            echo
        fi
    done
    
    print_message $YELLOW "Updating table: $selected_table"
    echo
    
    # Check if table has data
    data_file="$DBMS_HOME/$db_name/${selected_table}.data"
    if [ ! -s "$data_file" ]; then
        print_message $YELLOW "Table is empty - nothing to update"
        echo
        return
    fi
    
    # Display current table data
    print_message $BLUE "Current table data:"
    display_table_data "$db_name" "$selected_table"
    
    # Read table metadata
    declare -a columns
    declare -a data_types
    declare -a constraints
    
    while IFS=':' read -r col_name data_type constraint; do
        columns+=("$col_name")
        data_types+=("$data_type")
        constraints+=("$constraint")
    done < "$DBMS_HOME/$db_name/${selected_table}.meta"
    
    # Find primary key column (first column)
    primary_key_col="${columns[0]}"
    primary_key_type="${data_types[0]}"
    
    # Get primary key value to identify record
    while true; do
        echo -n "Enter $primary_key_col value of record to update: "
        read pk_value
        
        # Validate data type
        if [ "$primary_key_type" = "integer" ]; then
            if ! [[ "$pk_value" =~ ^-?[0-9]+$ ]]; then
                print_message $RED "❌ Invalid integer value!"
                continue
            fi
        fi
        
        # Check if record exists
        if ! grep -q "^$pk_value:" "$data_file"; then
            print_message $RED "❌ No record found with $primary_key_col = '$pk_value'"
            echo
            continue
        fi
        
        break
    done
    
    # Show current record
    print_message $YELLOW "Current record:"
    current_record=$(grep "^$pk_value:" "$data_file")
    IFS=':' read -ra current_values <<< "$current_record"
    
    for (( i = 0; i < ${#columns[@]}; i++ )); do
        print_message $BLUE "  ${columns[$i]}: ${current_values[$i]}"
    done
    echo
    
    # Choose columns to update (excluding primary key)
    print_message $YELLOW "Available columns to update:"
    for (( i = 1; i < ${#columns[@]}; i++ )); do
        print_message $GREEN "$i. ${columns[$i]} (${data_types[$i]}) - Current: ${current_values[$i]}"
    done
    echo
    
    while true; do
        echo -n "Enter column number to update (or 'done' when finished, 'back' to cancel): "
        read col_choice
        
        if [ "$col_choice" = "back" ]; then
            print_message $YELLOW "Update operation cancelled."
            echo
            return
        fi
        
        if [ "$col_choice" = "done" ]; then
            break
        fi
        
        if validate_positive_integer "$col_choice"; then
            if [ "$col_choice" -ge 1 ] && [ "$col_choice" -lt ${#columns[@]} ]; then
                col_index="$col_choice"
                col_name="${columns[$col_index]}"
                col_type="${data_types[$col_index]}"
                current_val="${current_values[$col_index]}"
                
                print_message $BLUE "Updating column: $col_name (${col_type})"
                print_message $BLUE "Current value: $current_val"
                
                while true; do
                    echo -n "Enter new value (or 'skip' to keep current): "
                    read new_value
                    
                    if [ "$new_value" = "skip" ]; then
                        break
                    fi
                    
                    # Validate data type
                    if [ "$col_type" = "integer" ]; then
                        if [[ "$new_value" =~ ^-?[0-9]+$ ]]; then
                            current_values[$col_index]="$new_value"
                            print_message $GREEN "✓ Column '$col_name' updated to: $new_value"
                            break
                        else
                            print_message $RED "❌ Invalid integer value!"
                        fi
                    else
                        # String type
                        if [ -n "$new_value" ]; then
                            current_values[$col_index]="$new_value"
                            print_message $GREEN "✓ Column '$col_name' updated to: $new_value"
                            break
                        else
                            print_message $RED "❌ Value cannot be empty!"
                        fi
                    fi
                done
                echo
            else
                print_message $RED "❌ Invalid column number!"
                echo
            fi
        else
            print_message $RED "❌ Please enter a valid number, 'done', or 'back'."
            echo
        fi
    done
    
    # Show updated record
    print_message $YELLOW "Updated record will be:"
    for (( i = 0; i < ${#columns[@]}; i++ )); do
        print_message $BLUE "  ${columns[$i]}: ${current_values[$i]}"
    done
    echo
    
    if ask_yes_no "Save these changes?"; then
        # Create new record string
        new_record=$(IFS=':'; echo "${current_values[*]}")
        
        # Create temporary file with updated record
        temp_file=$(mktemp)
        while IFS= read -r line; do
            if [[ "$line" =~ ^$pk_value: ]]; then
                echo "$new_record"
            else
                echo "$line"
            fi
        done < "$data_file" > "$temp_file"
        
        mv "$temp_file" "$data_file"
        print_message $GREEN "✓ Record updated successfully!"
    else
        print_message $YELLOW "Update operation cancelled."
    fi
    echo
}
