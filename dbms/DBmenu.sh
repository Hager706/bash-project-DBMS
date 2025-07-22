CURRENT_DB=""

DBmenu() {
    local db_name="$1"
    
    while true; do
        print_message $BLUE "╔════════════════════════════════╗"
        print_message $BLUE "║      Database: $db_name"       ║
        print_message $BLUE "╚════════════════════════════════╝"
        echo
        
        PS3="Please select an option (1-8): "
        select choice in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Back to Main Menu"; do
            case $choice in
                "Create Table") #done
                    create_table "$db_name"
                    break
                    ;;
                "List Tables")  #done <<< #work on it
                    list_tables "$db_name"
                    break
                    ;;
                "Drop Table")  #done <<< #work on it
                    drop_table "$db_name"
                    break
                    ;;
                "Insert into Table")  #work on it
                    insert_into_table "$db_name"
                    break
                    ;;
                "Select From Table")
                    select_from_table "$db_name"
                    break
                    ;;
                "Delete From Table")
                    delete_from_table "$db_name"
                    break
                    ;;
                "Update Table")
                    update_table "$db_name"
                    break
                    ;;
                "Back to Main Menu") #done
                    print_message $YELLOW "Disconnecting from database: $db_name"
                    CURRENT_DB=""
			echo
		    show_main_menu
                    ;;
                *)
                    print_message $RED "❌ Invalid option. Please try again."
                    break
                    ;;
            esac
        done
    done
}
#############################################################

create_table() {
    cd "$DBMS_HOME/$db_name" || return

    while true; do
        read -p "Enter table name: " table_name
        if ! validate_name "$table_name"; then echo ""; continue; fi
        if ! validate_string "$table_name"; then echo ""; continue; fi
        if ! validate_table_unique "$table_name"; then echo ""; continue; fi
        break 
    done

    touch "${table_name}.meta"
    if [ $? -ne 0 ]; then
        print_message $RED "❌ Failed to create table meta file!"
        return
    fi

    while true; do
        read -p "Enter number of columns (max 20): " columns_num
        if ! validate_positive_integer "$columns_num"; then echo ""; continue; fi
        if [ $columns_num -gt 20 ]; then
            print_message $RED "❌ Error: number of columns too large!"
            continue
        fi
        break
    done

    echo
    print_message $YELLOW "Note: The first column will be the PRIMARY KEY"
    echo

    # Header for .meta file
    {
        echo "# Table: $table_name"
        echo "# Columns: $columns_num"
        echo "# Format: column_name:data_type:constraint"
        echo "# Created: $(date)"
        echo ""
    } >> "${table_name}.meta"

    declare -a column_names
    declare -a data_types
    declare -a constraints

    for (( i = 1; i <= columns_num; i++ )); do
        echo ""

        while true; do
            if [ $i -eq 1 ]; then
                read -p "Enter PRIMARY KEY column name: " column_name
            else
                read -p "Enter column name for column $i: " column_name
            fi

            if ! validate_name "$column_name"; then echo ""; continue; fi
            if ! validate_string "$column_name"; then echo ""; continue; fi
            if ! validate_column_unique "$table_name" "$column_name"; then echo ""; continue; fi
            break
        done

        while true; do
            read -p "Enter column type for column $i (string/int/boolean): " column_type
            if ! validate_data_type "$column_type"; then echo ""; continue; fi
            break
        done

        column_names+=("$column_name")
        data_types+=("$column_type")
        if [ $i -eq 1 ]; then
            constraints+=("PRIMARY_KEY")
        else
            constraints+=("NONE")
        fi
    done

    # Save all columns to .meta file
    for (( i = 0; i < columns_num; i++ )); do
        echo "${column_names[$i]}:${data_types[$i]}:${constraints[$i]}" >> "${table_name}.meta"
    done

    # Create empty .data file with headers
    {
        for (( i = 0; i < columns_num; i++ )); do
            if [ $i -eq 0 ]; then
                echo -n "${column_names[$i]}"
            else
                echo -n ":${column_names[$i]}"
            fi
        done
        echo ""
    } > "${table_name}.data"

    print_message $GREEN "✓ Table '$table_name' created successfully!"
    pause_for_user
    show_created_table_structure "$table_name"
}
show_created_table_structure() {
    local table_name="$1"

    echo ""
    echo "📋 Table Structure: $table_name"
    echo "+----------------------+-------------+-----------------+"
    printf "| %-20s | %-11s | %-15s |\n" "Column Name" "Data Type" "Constraints"
    echo "+----------------------+-------------+-----------------+"

    awk -F: '
        NF > 0 && $0 !~ /^#/ {
            cname = $1
            dtype = $2
            constraint = ($3 == "" || $3 == "NONE") ? "NONE" : $3
            printf "| %-20s | %-11s | %-15s |\n", cname, dtype, constraint
        }
    ' "${table_name}.meta"

    echo "+----------------------+-------------+-----------------+"
}
##########################################################################
drop_table() {
    local db_name="$1"
    print_message $BLUE "=== Drop Table from Database: $db_name ==="
    echo
    
    # Show available tables
    meta_files=($(ls "$DBMS_HOME/$db_name"/*.meta 2>/dev/null))
    
    if [ ${#meta_files[@]} -eq 0 ]; then
        print_message $YELLOW "No tables found in database '$db_name'"
        echo
        return
    fi
    
    print_message $GREEN "Available tables:"
    for (( i = 0; i < ${#meta_files[@]}; i++ )); do
        table_name=$(basename "${meta_files[$i]}" .meta)
        
        record_count=0
        if [ -f "$DBMS_HOME/$db_name/${table_name}.data" ]; then
            record_count=$(wc -l < "$DBMS_HOME/$db_name/${table_name}.data")
        fi
        
        print_message $GREEN "$((i+1)). $table_name ($record_count records)"
    done
    echo
    
    while true; do
        echo -n "Enter table number to drop (or 'back' to return): "
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
    
    # Show table information before deletion
    print_message $YELLOW "Table to be dropped: $selected_table"
    echo
    
    # Show table structure
    print_message $BLUE "Table structure:"
    while IFS=':' read -r col_name data_type constraint; do
        constraint_text=""
        if [ "$constraint" = "PRIMARY_KEY" ]; then
            constraint_text=" (PRIMARY KEY)"
        fi
        print_message $GREEN "  - $col_name ($data_type)$constraint_text"
    done < "$DBMS_HOME/$db_name/${selected_table}.meta"
    echo
    
    # Show record count
    data_file="$DBMS_HOME/$db_name/${selected_table}.data"
    if [ -f "$data_file" ]; then
        record_count=$(wc -l < "$data_file")
        print_message $BLUE "Records in table: $record_count"
    else
        print_message $BLUE "Records in table: 0"
    fi
    echo
    
    # Confirmation warnings
    print_message $RED "⚠️  WARNING: This action will permanently delete the table and ALL its data!"
    echo
    
    if ask_yes_no "Are you sure you want to drop table '$selected_table'?"; then
            # Delete metadata file
            if [ -f "$DBMS_HOME/$db_name/${selected_table}.meta" ]; then
                rm "$DBMS_HOME/$db_name/${selected_table}.meta"
                print_message $GREEN "✓ Removed metadata file: ${selected_table}.meta"
            fi
            
            # Delete data file
            if [ -f "$DBMS_HOME/$db_name/${selected_table}.data" ]; then
                rm "$DBMS_HOME/$db_name/${selected_table}.data"
                print_message $GREEN "✓ Removed data file: ${selected_table}.data"
            fi
            
            print_message $GREEN "✓ Table '$selected_table' dropped successfully!"
            echo
        else
            print_message $YELLOW "Drop operation cancelled."
            echo
        fi
    else
        print_message $YELLOW "Drop operation cancelled."
        echo
    fi
}
##############################################################################
list_tables() {
    local db_name="$1"
    print_message $BLUE "=== Tables in Database: $db_name ==="
    echo
    
    # Check for .meta files
    meta_files=($(ls "$DBMS_HOME/$db_name"/*.meta 2>/dev/null))
    
    if [ ${#meta_files[@]} -eq 0 ]; then
        print_message $YELLOW "No tables found in database '$db_name'"
        echo
        return
    fi
    
    local count=0
    for meta_file in "${meta_files[@]}"; do
        table_name=$(basename "$meta_file" .meta)
        print_message $GREEN "✓ Table: $table_name"
        
        # Read and display table structure
        while IFS=':' read -r col_name data_type constraint; do
            constraint_text=""
            if [ "$constraint" = "PRIMARY_KEY" ]; then
                constraint_text=" (PRIMARY KEY)"
            fi
            print_message $BLUE "    - $col_name ($data_type)$constraint_text"
        done < "$meta_file"
        
        # Count records
        if [ -f "$DBMS_HOME/$db_name/${table_name}.data" ]; then
            record_count=$(wc -l < "$DBMS_HOME/$db_name/${table_name}.data")
            print_message $YELLOW "    Records: $record_count"
        fi
        
        echo
        ((count++))
    done
    
    print_message $BLUE "Total tables: $count"
    echo
}

##############################################################################

insert_into_table() {
    
}