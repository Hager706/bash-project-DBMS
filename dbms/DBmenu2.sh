select_from_table() {

print_message $BLUE "Select Data from Tables in Database: $1"
local found=0
local count=1
declare -a table_names=()
declare -a columns
for file in *.meta
do
        if [ -f "$file" ]
        then
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

    if [ $found -eq 0 ]
    then
        echo ""
        print_message $RED "❌ No tables found "
        echo " "
        if ask_yes_no "Do you want to create a table?" 
        then
            create_table "$1"
            echo ""
            return
        fi
        DBmenu $1
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
           print_message $RED "❌ Invalid table number"
           echo ""
           continue
        fi 
        break
    done

    table_name="${table_names[$((number-1))]}"
while true
do
PS3="Please select an option (1-4): "
        select choice in "View all records" "View specific record" "View specific columns" "Back to database Menu"; do
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
                *)
                    print_message $RED "❌ Invalid option. Please try again."
                    break
                    ;;
            esac
        done
    done
# Show available tables √
# Let user select a table √
# Provide options:√
# View all records √
# View specific record by primary key
# View specific columns only
# Display data in formatted table

# Expected User Flow:
# Select Data
# Available tables: employees, departments
# Enter table name: employees
# Select option:
# 1) View all records
# 2) View specific record
# 3) View specific columns
# Choice: 1

# === employees table ===
# ID    | Name      | Salary
# ------|-----------|-------
# 1     | John Doe  | 50000
# 2     | Jane Smith| 60000
}
Viewall() {
local table="$1"
local data_file="${table}.data"
 
    if [ ! -f "$data_file" ]; then
        print_message $RED "❌ Error: Data file for table '$table' not found!"
        return 1
    fi
 
    echo ""
    print_message $BLUE "=== $table table ==="
    echo
 
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
    
    if [ ! -f "$data_file" ]; then
        print_message $RED "❌ Error: Data file for table '$table' not found!"
        return 1
    fi
    
    if [ ! -f "$meta_file" ]; then
        print_message $RED "❌ Error: Meta file for table '$table' not found!"
        return 1
    fi
    
    # Read primary key from meta file (first line, first column)
    local primary_key=$(head -n 1 "$meta_file" | cut -d':' -f1)
    
    echo ""
    print_message $BLUE "=== View Specific Record from $table table ==="
    echo ""
    
    # Show available records with their primary key values
    print_message $GREEN "Available records (showing $primary_key values):"
    echo ""
    
    # Read header
    IFS= read -r header < "$data_file"
    IFS=':' read -ra columns <<< "$header"
    
    # Find primary key index
    local pk_index=0
    for i in "${!columns[@]}"; do
        if [ "${columns[$i]}" = "$primary_key" ]; then
            pk_index=$i
            break
        fi
    done
    
    # Show available primary key values
    tail -n +2 "$data_file" | while IFS=':' read -ra fields; do
        echo "- ${fields[$pk_index]}"
    done
    
    echo ""
    while true; do
        echo -n "Enter the $primary_key value of the record to view (or 'back' to return): "
        read pk_value
        
        if [ "$pk_value" = "back" ]; then
            return
        fi
        
        if [ -z "$pk_value" ]; then
            print_message $RED "❌ Please enter a valid $primary_key value"
            continue
        fi
        
        # Search for the record
        local found=0
        declare -a record_fields=()
        
        while IFS=':' read -ra fields; do
            if [ "${fields[$pk_index]}" = "$pk_value" ]; then
                found=1
                record_fields=("${fields[@]}")
                break
            fi
        done < <(tail -n +2 "$data_file")
        
        if [ $found -eq 0 ]; then
            print_message $RED "❌ No record found with $primary_key = $pk_value"
            continue
        fi
        
        # Display the found record
        echo ""
        print_message $BLUE "=== Record Details ==="
        
        # Print header
        printf "|"
        for col in "${columns[@]}"; do
            printf " %-15s |" "$col"
        done
        echo
        
        # Print separator
        printf "|"
        for _ in "${columns[@]}"; do
            printf -- "-----------------|"
        done
        echo
        
        # Print the record
        printf "|"
        for field in "${record_fields[@]}"; do
            printf " %-15s |" "$field"
        done
        echo
        echo ""
        
        break
    done
}

ViewspecCol() {
    local table="$1"
    local data_file="${table}.data"
    
    if [ ! -f "$data_file" ]; then
        print_message $RED "❌ Error: Data file for table '$table' not found!"
        return 1
    fi
    
    echo ""
    print_message $BLUE "=== View Specific Columns from $table table ==="
    echo ""
    
    # Read header
    IFS= read -r header < "$data_file"
    IFS=':' read -ra columns <<< "$header"
    
    # Show available columns
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
            print_message $RED "❌ Please enter at least one column number"
            continue
        fi
        
        # Validate selected numbers
        local valid=1
        declare -a selected_indices=()
        
        for num in "${selected_numbers[@]}"; do
            if ! validate_positive_integer "$num"; then
                print_message $RED "❌ Invalid number: $num"
                valid=0
                break
            fi
            
            if [ "$num" -lt 1 ] || [ "$num" -gt ${#columns[@]} ]; then
                print_message $RED "❌ Column number $num is out of range (1-${#columns[@]})"
                valid=0
                break
            fi
            
            selected_indices+=($((num-1)))
        done
        
        if [ $valid -eq 0 ]; then
            continue
        fi
        
        # Display selected columns
        echo ""
        print_message $BLUE "=== Selected Columns from $table table ==="
        echo ""
        
        # Print selected column headers
        printf "|"
        for index in "${selected_indices[@]}"; do
            printf " %-15s |" "${columns[$index]}"
        done
        echo
        
        # Print separator
        printf "|"
        for _ in "${selected_indices[@]}"; do
            printf -- "-----------------|"
        done
        echo
        
        # Print data for selected columns
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
print_message $BLUE "Delete Data from Tables in Database: $1"
local found=0
local count=1
declare -a table_names=()
declare -a columns
for file in *.meta
do
        if [ -f "$file" ]
        then
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

    if [ $found -eq 0 ]
    then
        echo ""
        print_message $RED "❌ No tables found "
        echo " "
        if ask_yes_no "Do you want to create a table?" 
        then
            create_table "$1"
            echo ""
            return
        fi
        DBmenu $1
        return
    fi
    echo 

while true
do 
        echo -n "Enter the number of the table to delete from:(or 'back' to return): "
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
           print_message $RED "❌ Invalid table number"
           echo ""
           continue
        fi 
        break
    done

    table_name="${table_names[$((number-1))]}"
while true
do
PS3="Please select an option (1-3): "
        select choice in "Delete specific record by primary key" "Delete all records" "Back to database Menu"
        do
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
                    DBmenu "$1"
                    ;;
                *)
                    print_message $RED "❌ Invalid option. Please try again."
                    break
                    ;;
            esac
        done
    done

# Show available tables √
# Let user select a table √
# Provide options:√
#   Delete specific record by primary key√
#   Delete all records (keep table structure)√
# Confirm deletion before proceeding 
# Update .data file

# Delete Data
# Available tables: employees
# Enter table name: employees
# Select option:
# 1) Delete specific record
# 2) Delete all records
# Choice: 1
# Enter primary key value to delete: 1
# Record found: 1:John Doe:50000
# Are you sure you want to delete this record? (y/n): y
# ✓ Record deleted successfully!
}
DeletespecRec() {
    local table="$1"
    local data_file="${table}.data"
    local meta_file="${table}.meta"
    
    Viewall "$table"
    
    if [ ! -f "$data_file" ]; then
        print_message $RED "❌ Error: Data file for table '$table' not found!"
        return 1
    fi
    
    if [ ! -f "$meta_file" ]; then
        print_message $RED "❌ Error: Meta file for table '$table' not found!"
        return 1
    fi
    
    local primary_key=$(head -n 1 "$meta_file" | cut -d':' -f1)
    
    IFS= read -r header < "$data_file"
    IFS=':' read -ra columns <<< "$header"
    
    local pk_index=0
    for i in "${!columns[@]}"; do
        if [ "${columns[$i]}" = "$primary_key" ]; then
            pk_index=$i
            break
        fi
    done
    
    if [ $pk_index -eq 0 ] && [ "${columns[0]}" != "$primary_key" ]; then
        print_message $RED "❌ Error: Primary key '$primary_key' not found in table '$table'!"
        return 1
    fi
    
    echo ""
    while true; do
        echo -n "Enter the $primary_key value of the record to delete (or 'back' to return): "
        read pk_value
        
        if [ "$pk_value" = "back" ]; then
            return
        fi
        
        if [ -z "$pk_value" ]; then
            print_message $RED "❌ Please enter a valid $primary_key value"
            continue
        fi
        
        local found=0
        declare -a record_fields=()
        
        while IFS=':' read -ra fields; do
            if [ "${fields[$pk_index]}" = "$pk_value" ]; then
                found=1
                record_fields=("${fields[@]}")
                break
            fi
        done < <(tail -n +2 "$data_file")
        
        if [ $found -eq 0 ]; then
            print_message $RED "❌ No record found with $primary_key = $pk_value"
            continue
        fi
        
        # Display the record to be deleted
        echo ""
        print_message $YELLOW "⚠️  Record to be deleted:"
        echo ""
        
        # Print header
        printf "|"
        for col in "${columns[@]}"; do
            printf " %-15s |" "$col"
        done
        echo
        
        # Print separator
        printf "|"
        for _ in "${columns[@]}"; do
            printf -- "-----------------|"
        done
        echo
        
        # Print the record
        printf "|"
        for field in "${record_fields[@]}"; do
            printf " %-15s |" "$field"
        done
        echo
        echo ""
        
        # Confirm deletion
        if ask_yes_no "Are you sure you want to delete this record? This action cannot be undone"; then
            # Use sed to delete the line that contains the primary key value
            # Escape special characters in pk_value for sed
            local escaped_pk_value=$(printf '%s\n' "$pk_value" | sed 's/[[\.*^$()+?{|]/\\&/g')
            
            # Delete the line that starts with the primary key value (considering it's the first column)
            if [ $pk_index -eq 0 ]; then
                # Primary key is first column
                sed -i "/^${escaped_pk_value}:/d" "$data_file"
            else
                # Primary key is in another column - use awk for more precise matching
                awk -F':' -v pk_idx=$((pk_index+1)) -v pk_val="$pk_value" '$pk_idx != pk_val' "$data_file" > "${data_file}.tmp" && mv "${data_file}.tmp" "$data_file"
            fi
            
            echo ""
            print_message $GREEN "✅ Record with $primary_key = $pk_value deleted successfully!"
            echo ""
            
            # Show updated table
            print_message $BLUE "Updated table:"
            Viewall "$table"
        else
            print_message $BLUE "❌ Deletion cancelled"
            echo ""
        fi
        
        break
    done
}

# Function to delete all records (keep table structure)
DeleteAll() {
    local table="$1"
    local data_file="${table}.data"
    
    if [ ! -f "$data_file" ]; then
        print_message $RED "❌ Error: Data file for table '$table' not found!"
        return 1
    fi
    
    # Show current table
    Viewall "$table"
    echo ""
    
    # Count current records
    local record_count=$(($(wc -l < "$data_file") - 1))
    
    if [ $record_count -eq 0 ]; then
        print_message $YELLOW "⚠️  Table '$table' is already empty"
        return 0
    fi
    
    print_message $YELLOW "⚠️  This will delete ALL $record_count records from table '$table'"
    print_message $YELLOW "⚠️  The table structure will be preserved (columns will remain)"
    echo ""
    
    if ask_yes_no "Are you sure you want to delete ALL records? This action cannot be undone"; then
        # Delete all lines except the header (line 1)
        sed -i '2,$d' "$data_file"
        
        echo ""
        print_message $GREEN "✅ All records deleted successfully from table '$table'"
        print_message $BLUE "Table structure preserved. You can add new records anytime."
        echo ""
        
        # Show empty table
        Viewall "$table"
    else
        print_message $BLUE "❌ Deletion cancelled"
        echo ""
    fi
}