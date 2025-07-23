CURRENT_DB=""

DBmenu() {
    
    while true; do
        print_message $BLUE "╔════════════════════════════════╗"
        print_message $BLUE "║       Database: $1"            ║
        print_message $BLUE "╚════════════════════════════════╝"
        echo
        
        PS3="Please select an option (1-8): "
        select choice in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Back to Main Menu"; do
            case $choice in
                "Create Table") #done
                    create_table "$1"
                    break
                    ;;
                "List Tables")  #done <<< #work on it
                    list_tables "$1"
                    break
                    ;;
                "Drop Table")  #done <<< #work on it
                    drop_table "$1"
                    break
                    ;;
                "Insert into Table")  #work on it
                    insert_into_table "$1"
                    break
                    ;;
                "Select From Table")   #work on it
                    select_from_table "$1"
                    break
                    ;;
                "Delete From Table")    #work on it
                    delete_from_table "$1"
                    break
                    ;;
                "Update Table")     #work on it
                    update_table "$1"
                    break
                    ;;
                "Back to Main Menu") #done
                    print_message $YELLOW "Disconnecting from database: $1"
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
cd "$DBMS_HOME/$1" || return

    while true
    do
        read -p "Enter table name: "  table_name
        if ! validate_name "$table_name"
        then 
        echo ""
        continue
        fi

        if ! validate_string "$table_name"
        then 
        echo ""
        continue
        fi

        if ! validate_table_unique "$table_name"
        then echo ""
        continue
        fi

        break 
    done

    touch "${table_name}.meta"
    if [ $? -ne 0 ]; then
        print_message $RED "❌ Failed to create table meta file!"
        return
    fi

    while true
    do
        read -p "Enter number of columns (max 20): " columns_num
        if ! validate_positive_integer "$columns_num"
        then 
        echo ""
        continue
        fi

        if [ $columns_num -gt 20 ]
        then
            print_message $RED "❌ Error: number of columns too large!"
            continue
        fi
        break
    done

    echo
    print_message $YELLOW "Note: The first column will be the PRIMARY KEY"
    echo

    declare -a column_names
    declare -a data_types
    declare -a constraints

    for (( i = 1; i <= columns_num; i++ ))
    do
        echo ""

        while true
        do
            if [ $i -eq 1 ]
            then
                read -p "Enter PRIMARY KEY column name: " column_name
            else
                read -p "Enter column name for column $i: " column_name
            fi


            if ! validate_name "$column_name"
            then echo ""
            continue
            fi

            if ! validate_string "$column_name"
            then echo ""
            continue
            fi

            if ! validate_column_unique "$table_name" "$column_name"
            then echo ""
            continue
            fi

            break
        done

        while true
        do
            read -p "Enter column type for column $i (string/int/boolean): " column_type
            if ! validate_data_type "$column_type"
            then echo ""
            continue; fi
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
    # pause_for_user
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

##############################################################################
list_tables() {
local found=0

    #cd "$DBMS_HOME/$1" || return
    print_message $BLUE "Tables in Database: $1"
    echo
    for file in *.meta
    do
        # if [  ! -s "$file" ]
        # then 
        # table_name="${file%.meta}"
        # print_message $YELLOW "⚠️ Table '$table_name' is empty or corrupted."
        # continue
        # fi


        if [ -f "$file" ]
        then
            found=1
            table_name="${file%.meta}"
            show_created_table_structure "$table_name"
        fi
       
    done

    if [ $found -eq 0 ]
    then
        print_message $RED "❌ No tables found "
    fi
    echo 

}

##############################################################################
drop_table() {
local found=0
local count=1
declare -a table_names=()
print_message $BLUE "Drop Tables in Database: $1"
for file in *.meta
do

        if [ -f "$file" ]
        then
           if [ $found -eq 0 ]; then
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
        echo -n "Enter the number of the table to drop:(or 'back' to return): "
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
    show_created_table_structure "$table_name"
    print_message $RED "⚠️  WARNING: This action will permanently delete the table and ALL its data!"
    echo


    table_name="${table_names[$((number-1))]}"
    if ask_yes_no "Are you sure you want to drop table '$table_name'?"
    then
            if [ -f "$DBMS_HOME/$db_name/${table_name}.meta" ]
            then
                rm "$DBMS_HOME/$db_name/${table_name}.meta"
                print_message $GREEN "✓ Removed metadata file: ${table_name}.meta"
            fi
            if [ -f "$DBMS_HOME/$db_name/${table_name}.data" ]; then
                rm "$DBMS_HOME/$db_name/${table_name}.data"
                print_message $GREEN "✓ Removed data file: ${table_name}.data"
            fi
            print_message $GREEN "✓ Table '$table_name' dropped successfully!"

    else
        print_message $YELLOW "Drop operation cancelled."
        echo
    fi
}

##########################################################################

insert_into_table() {
print_message $BLUE "Insert Data in Tables in Database: $1"
local found=0
local count=1
declare -a table_names=()
declare -a columns
declare -a data_types
declare -a constraints
declare -a values
for file in *.meta
do
        if [ -f "$file" ]
        then
           if [ $found -eq 0 ]; then
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
        echo -n "Enter the number of the table to insert into:(or 'back' to return): "
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

# awk -F: '
#     NF > 0 && $0 !~ /^#/ {
#         cname = $1
#         dtype = $2
#         constraint = ($3 == "" || $3 == "NONE") ? "" : ", " $3
#         printf "Enter value for %s (%s%s):\n", cname, dtype, constraint
#     }
# ' "${table_name}.meta"

while IFS=':' read -r  colName dataType const 
do
columns+=("$colName")
data_types+=("$dataType")
constraints+=("$const")

done  < "$DBMS_HOME/$1/${table_name}.meta" 
while true
do
values=()
for (( i=0 ; i<${#columns[@]} ; i++))
do 
  while true
  do 
     constraint_text=""
     if [[ "$constraints[$i]" == "PRIMARY_KEY" ]]
     then
        constraint_text=" (PRIMARY KEY)"
     fi
     echo -n "Enter value for ${columns[$i]} (${data_types[$i]}$constraint_text):"
     read value


     if ! validate_column_value "$value" "${data_types[$i]}"
     then
        echo ""
        continue
     fi

     if [[ "${constraints[$i]}" == "PRIMARY_KEY" ]] && ! validate_primary_key_unique "$table_name" "$value"
     then
                echo ""
                continue
     fi
     values+=("$value")

     break

  done 

done 
    record=$(IFS=':'; echo "${values[*]}")
    echo "$record" >> "$DBMS_HOME/$1/${table_name}.data"
    
    print_message $GREEN "✓ Record inserted successfully!"
    echo
    print_message $YELLOW "Inserted record:"
    echo "+----------------------+----------------------+"
    printf "| %-20s | %-20s |\n" "Column Name" "Value"
    echo "+----------------------+----------------------+"

    for (( i = 0; i < ${#columns[@]}; i++ )); do
    printf "| %-20s | %-20s |\n" "${columns[$i]}" "${values[$i]}" 
    done

    echo "+----------------------+----------------------+"

    echo
if ! ask_yes_no "Do you want to insert another record into '$table_name'?"
then
    break
fi
done
echo ""
DBmenu "$1"
}


# 1. Show available tables √
# 2. Let user select a table √
# 3. Read table structure from .meta file √
# 4. Prompt for each column value
# 5. Validate data types (integer vs string)
# 6. Check primary key uniqueness
# 7. Append data to .data file

# Insert Data
# Available tables: employees, departments√
# Enter table name: employees√
# Enter value for id (integer, Primary Key): 1
# Enter value for name (string): John Doe
# Enter value for salary (integer): 50000
# ✓ Record inserted successfully!