show_main_menu() {
    local db_name="$1"
       PS3="Select an option (1-5): "
select choice in "Create Database" "Connect to Database" "List Databases" "Drop Database" "Exit"
do
      case $choice in
            "Create Database")
             create_database
                  break
                  ;;
            "Connect to Database")
             connect_to_database
                  break
                  ;;
            "List Databases")
            list_databases
                  break
                  ;;
            "Drop Database")
            echo "Drop Database feature - Coming in Step 3!"
                  break
                  ;;
            "Exit")
            echo "Goodbye! Thank you for using our DBMS."
                  exit 0
                  ;;
            *)
            echo $RED"❌ Invalid option. Please select 1-5."
                  break
                  ;;
            esac
        done
 

}
create_database() {

      
}

drop_database() {}
create_database() {}
list_databases() {}
connect_to_database() {}
delete_database() {}
select_database() {}
