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
local count=0

for file in *.meta
do
if [ -f "$file" ]
        then
            found=1
            table_name="${file%.meta}"
             print_message $GREEN "$((count+1)). $table_name"
             count=$((count+1))
        fi
       
    done

    if [ $found -eq 0 ]
    then
        print_message $RED "❌ No tables found "
    fi
    echo 

    while true
    do 
        echo -n "Enter the number of the table to drop: "
        read number

        if ! validate_positive_integer "$number"
        then
            echo ""
            continue
        fi 
            number_in_arr=$((number - 1))
        if [ "$number_in_arr" -ge 0 ] && [ "$number_in_arr" -lt $count ]; then
                selected_table="${var[$number_in_arr]}"
                break
        fi
    done
}

##########################################################################

insert_into_table() {
    
}