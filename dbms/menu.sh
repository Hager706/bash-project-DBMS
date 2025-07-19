show_main_menu() {
print_message $BLUE "*** DBMS Main Menu ***"
    local db_name="$1"
       PS3="Select an option (1-4): "
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
                 continue
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
            print_message $RED"❌ Invalid option. Please select 1-4."
            echo
                  continue
                  ;;
            esac
        done
 

}
create_database() {
    while true
    do
      read -p "Enter database name: " db_name
      if ! validate_name "$db_name" "database name"; then
            echo "Please try again with a valid name."
            echo ""
            continue
      fi
        
      if ! validate_database_unique "$db_name"; then
            echo "Please choose a different name."
            echo ""
            continue
      fi
        
      mkdir -p "$db_name"
      if [ $? -eq 0 ]; then
            print_message $GREEN "✓ Database '$db_name' created successfully!"
            print_message $GREEN "✓ Location: $DBMS_HOME/$db_name"
            echo
            
            echo -n "Would you like to connect to this database now? (y/n): "
            read connect_choice
            if [[ "$connect_choice" =~ ^[Yy]([Ee][Ss])?$ ]]; then
                print_message $YELLOW "Connecting to database '$db_name'..."
                print_message $YELLOW "Database connection functionality will be implemented next..."
            fi
               echo
               return
      else
            print_message $RED "✗ Failed to create database '$db_name'"
            echo
      fi
            

done
}

list_databases() {
    if [ -z "$(ls -A "$DBMS_HOME" 2>/dev/null)" ]; then
        print_message $RED "No databases found!"
        echo -n "Do you want to create a database? (y/n): "
        read create_choice

        if [[ "$create_choice" =~ ^[Yy]([Ee][Ss])?$ ]]; then
            create_database
        fi
    else
	
	print_message $GREEN "Existing databases:"

	var=($(ls -A "$DBMS_HOME"))

	for (( i = 0; i < ${#var[@]}; i++ ))
	do
    	print_message $GREEN "$((i+1)). ${var[$i]}"
	done
	echo

      if ask_yes_no "Would you like to connect to a database now?"
      then
      echo -n "Enter the number of the database to connect: "
      read number 
        if validate_positive_integer $number
	  then
		number_in_arr=$((number-1)) 
		if [ "$number_in_arr" -ge 0 ] && [ "$number_in_arr" -lt ${#var[@]} ]
		then
			selected_db="${var[$index]}" 
			print_message $BLUE "Connecting to database '$selected_db'..."
			connect_to_database "$selected_db"
		else
			print_message $RED "❌ Invalid number! Please choose a number from the list."
		fi
        fi 
      else  
    print_message $YELLOW "Returning to main menu..."
    show_main_menu
      fi

    fi
}

connect_to_database() {}
drop_database() {}
