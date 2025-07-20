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

1- i expect that i asked from user to enter table name of table 
2-i will ask user to enter number of columns 
3-i will create table with that number of columns 
4- if user enter 2 then i will consider the primary key will be the first column
5- if user enter 3 then i will consider the primary key will be the first column
6- afet 

}
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