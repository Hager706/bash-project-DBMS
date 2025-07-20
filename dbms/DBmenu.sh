CURRENT_DB=""
DBmenu() {
    local db_name="$1"
    
    while true; do
        print_message $BLUE "╔════════════════════════════════╗"
        print_message $BLUE "║      Database: $db_name"        ║
        print_message $BLUE "╚════════════════════════════════╝"
        echo
        
        PS3="Please select an option (1-8): "
        select choice in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Back to Main Menu"; do
            case $choice in
                "Create Table")
                    create_table "$db_name"
                    break
                    ;;
                "List Tables")
                    list_tables "$db_name"
                    break
                    ;;
                "Drop Table")
                    drop_table "$db_name"
                    break
                    ;;
                "Insert into Table")
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
                "Back to Main Menu")
                    print_message $YELLOW "Disconnecting from database: $db_name"
                    CURRENT_DB=""
                    return
                    ;;
                *)
                    print_message $RED "❌ Invalid option. Please try again."
                    break
                    ;;
            esac
        done
    done
}

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

    for (( i = 0; i < columns_num; i++ )); do
        echo "${column_names[$i]}:${data_types[$i]}:${constraints[$i]}" >> "${table_name}.meta"
    done

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
    echo "==============================="
    printf "%-20s %-12s %-15s\n" "Column Name" "Data Type" "Constraints"
    printf "%-20s %-12s %-15s\n" "--------------------" "------------" "---------------"
    
    awk -F: '!/^#/ && NF > 0 {
        constraints = ""
        if ($3 == "PK") constraints = "Primary Key"
        printf "%-20s %-12s %-15s\n", $1, $2, constraints
    }' "${table_name}.meta"
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
1- i expect that i asked from user to enter table name of table 
2-i will ask user to enter number of columns 
3-i will create table with that number of columns 
4- if user enter 2 then i will consider the primary key will be the first column
5- if user enter 3 then i will consider the primary key will be the first column
6- every column i will  about the type and name of the column 
7- i will save the table in the database folder


list_tables() {
}
insert_into_table() {
}
select_from_table() {
}
delete_from_table() {
}
update_table() {
}
display_table_data() {
}
delete_from_table() {
}
update_table() {
}

drop_table() {
}