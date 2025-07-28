select_from_table() {
echo
print_message $BLUE "█▓▒░ SELECT DATA FROM TABLE $1 ░▒▓█"
echo
    if ! cd "$DBMS_HOME/$1" 2>/dev/null; then
        print_message $RED "✗ Error: Cannot access database directory"
        return 1
    fi
list_tables "$1"
echo
   if [ ${#table_names[@]} -eq 0 ]; then
        return
    fi
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

        if [ "$number" -lt 1 ] || [ "$number" -gt ${#table_names[@]} ]
        then 
            print_message $RED "✗ Invalid table number (1-${#table_names[@]})"
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
echo
print_message $BLUE "█▓▒░ DELETE DATA FROM TABLE $1 ░▒▓█"
echo
list_tables "$1"
echo

    while true
    do 
        echo -n "Enter the number of the table to delete from (or 'back' to return): "
        read number
        if [ "$number" = "back" ]; then
            return
        fi
        if ! validate_positive_integer "$number"
        then
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

    table_choise="${table_names[$((number-1))]}"
    
    while true; do
        echo
        print_message $BLUE "╭━━━━━━━━━━━━[  $table_choise  ]━━━━━━━━━━━━━━╮"
        print_message $BLUE "┃    Delete Options for Table        ┃"
        print_message $BLUE "╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯"
        echo
        
        PS3="Please select an option (1-3): "
        select choice in "Delete specific record by primary key" "Delete all records" "Back to database Menu" "Exit"; do
            case $choice in
                "Delete specific record by primary key") 
                    DeletespecRec "$table_choise"
                    break
                    ;;
                "Delete all records")  
                    DeleteAll "$table_choise"
                    break
                    ;;
                "Back to database Menu") 
                    echo
                    return  
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
local table_name="$1"
local data_file="${table_name}.data"
    
    echo
    print_message $BLUE "Delete Specific Record from Table: $table_name "
    echo
    
    if [ ! -f "$data_file" ]; then
        print_message $RED "✗ Error: Data file for table '$table_name' not found!"
        return 1
    fi
    
    local record_count=$(($(wc -l < "$data_file") - 1))
    if [ "$record_count" -eq 0 ]; then
        print_message $YELLOW "⚠️ Table '$table_name' is empty - nothing to delete"
        return
    fi
    
    echo
    print_message $BLUE "Current table data:"
    Viewall "$table"
    echo
    
    local primary_key=$(head -n 1 "$data_file" | cut -d':' -f1)
    
    while true; do
        echo -n "Enter the $primary_key value of the record to delete (or 'back' to return): "
        read pk_value
        
        if [ "$pk_value" = "back" ]; then
            return
        fi
        
        if [ -z "$pk_value" ]; then
            print_message $RED "✗ Please enter a valid $primary_key value"
            continue
        fi
        
        local found_record=$(grep "^${pk_value}:" "$data_file")
        
        if [ -z "$found_record" ]; then
            print_message $RED "✗ No record found with $primary_key = '$pk_value'"
            continue
        fi
        
        echo
        print_message $YELLOW "⚠️ Record to be deleted:"
        echo "$found_record" | tr ':' '\t'
        echo
        
        if ask_yes_no "Are you sure you want to delete this record? This action cannot be undone"; then
            
            sed -i "/^${pk_value}:/d" "$data_file"
            
            if [ $? -eq 0 ]; then
                echo
                print_message $GREEN "✓ Record with $primary_key = '$pk_value' deleted successfully!"
                echo
                
                print_message $BLUE "Remaining records:"
                Viewall "$table_name"
            else
                print_message $RED "✗ Error: Failed to delete record"
            fi
        else
            print_message $YELLOW "Deletion cancelled"
            echo
        fi
        
        break
    done
}
 


DeleteAll() {
local table_name="$1"
local data_file="${table_name}.data"
    
    echo
    print_message $BLUE "Delete Specific Record from Table: $table_name "
    echo
    
    if [ ! -f "$data_file" ]; then
        print_message $RED "✗ Error: Data file for table '$table_name' not found!"
        return 1
    fi
    
    local record_count=$(($(wc -l < "$data_file") - 1))
    if [ "$record_count" -eq 0 ]; then
        print_message $YELLOW "⚠️ Table '$table_name' is empty - nothing to delete"
        return
    fi
 
    echo
    print_message $BLUE "Current table data:"
    Viewall "$table_name"
    echo
    
    print_message $YELLOW "⚠️ This will delete ALL $record_count records from table '$table'"
    print_message $YELLOW "⚠️ The table structure will be preserved (columns will remain)"
    echo
    
    if ask_yes_no "Are you sure you want to delete ALL records? This action cannot be undone"; then
        
        sed -i '2,$d' "$data_file"
        
        if [ $? -eq 0 ]; then
            echo
            print_message $GREEN "✓ All records deleted successfully from table '$table_name'"
            print_message $BLUE "Table structure preserved. You can add new records anytime."
            echo
            
            echo "Table is now empty:"
            head -n 1 "$data_file" | tr ':' '\t'
            echo
        else
            print_message $RED "✗ Error: Failed to delete records"
        fi
    else
        print_message $YELLOW "Deletion cancelled"
        echo
    fi
}



update_table() {
    echo
print_message $BLUE "█▓▒░ UPDATE DATA FROM TABLE $1 ░▒▓█"
echo
list_tables "$1"
echo

    while true
    do 
        echo -n "Enter the number of the table to update (or 'back' to return): "
        read number
        if [ "$number" = "back" ]; then
            return
        fi
        if ! validate_positive_integer "$number"
        then
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

    table_choise="${table_names[$((number-1))]}"
    
    local data_file="${table_choise}.data"
    local meta_file="${table_choise}.meta"
    
    echo
    print_message $BLUE "Update Record in Table: $table_choise"
    echo
    
    if [ ! -f "$data_file" ]; then
        print_message $RED "✗ Error: Data file for table '$table_choise' not found!"
        return 1
    fi
    
    local record_count=$(($(wc -l < "$data_file") - 1))
    if [ "$record_count" -eq 0 ]; then
        print_message $YELLOW "⚠️ Table '$table_choise' is empty - nothing to update"
        return
    fi
    
    echo
    print_message $BLUE "Current table data:"
    Viewall "$table_choise"
    echo
    
    local primary_key=$(head -n 1 "$data_file" | cut -d':' -f1)
    
    while true; do
        echo -n "Enter the $primary_key value of the record to update (or 'back' to return): "
        read pk_value
        
        if [ "$pk_value" = "back" ]; then
            return
        fi
        
        if [ -z "$pk_value" ]; then
            print_message $RED "✗ Please enter a valid $primary_key value"
            continue
        fi
        
        local found_record=$(grep "^${pk_value}:" "$data_file")
        
        if [ -z "$found_record" ]; then
            print_message $RED "✗ No record found with $primary_key = '$pk_value'"
            continue
        fi
        
        echo
        print_message $YELLOW "⚠️ Current record:"
        echo "$found_record" | tr ':' '\t'
        echo
        
        declare -a columns
        declare -a data_types
        while IFS=':' read -r col_name data_type constraint; do
            if [ -n "$col_name" ]; then
                columns+=("$col_name")
                data_types+=("$data_type")
            fi
        done < "$meta_file"
        
        IFS=':' read -ra current_values <<< "$found_record"
        
        echo "Enter new values "
        echo
        
        for (( i = 1; i < ${#columns[@]}; i++ )); do
            local col_name="${columns[$i]}"
            local col_type="${data_types[$i]}"
            
            while true; do
                echo -n "${col_name} (${col_type})"
                read new_value
                            
                if validate_column_value "$new_value" "$col_type"
                then
                    current_values[$i]="$new_value"
                    break
                fi
                echo
            done
        done
        
        local new_record=$(IFS=':'; echo "${current_values[*]}")
        
        echo
        print_message $YELLOW "⚠️ Updated record will be:"
        echo "$new_record" | tr ':' '\t'
        echo
        
        if ask_yes_no "Are you sure you want to update this record? This action cannot be undone"; then
            
            sed -i "s/^${pk_value}:.*/${new_record}/" "$data_file"
            
            if [ $? -eq 0 ]; then
                echo
                print_message $GREEN "✓ Record with $primary_key = '$pk_value' updated successfully!"
                echo
                
                print_message $BLUE "Updated table:"
                Viewall "$table_choise"
            else
                print_message $RED "✗ Error: Failed to update record"
            fi
        else
            print_message $YELLOW "Update cancelled"
            echo
        fi
        
        break
    done
}