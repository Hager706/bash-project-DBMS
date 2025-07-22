show_main_menu() {
while true; do
print_message $BLUE "*** DBMS Main Menu ***"
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
                 continue
                  ;;
            "Drop Database")
 
		drop_database                
		 continue
                  ;;
              "exit" )
           print_message $GREEN "Goodbye! Thank you for using our DBMS."
                  exit 0
                  ;;
            *)
            print_message $RED"❌ Invalid option. Please select 1-5."
            echo
                  continue
                  ;;
            esac
           
        done
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
            if ask_yes_no "Would you like to connect to this database now?"
            then
                print_message $YELLOW "Connecting to database '$db_name'..."
		connect_to_database
	    else
                 show_main_menu
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
        if ask_yes_no "Do you want to create a database?"
        then
            create_database
        else
            print_message $YELLOW "Returning to main menu..."
            show_main_menu
        fi
    else

        var=($(ls -A "$DBMS_HOME"))
        print_message $GREEN "Found ${#var[@]} databases:"


        for (( i = 0; i < ${#var[@]}; i++ ))
        do
            print_message $GREEN "$((i+1)). ${var[$i]}"
        done
        echo

        if ask_yes_no "Would you like to connect to a database now?"
        then
            while true; do
                echo -n "Enter the number of the database to connect: "
                read number

                if validate_positive_integer "$number"; then
                    number_in_arr=$((number - 1))
                    if [ "$number_in_arr" -ge 0 ] && [ "$number_in_arr" -lt ${#var[@]} ]; then
                        selected_db="${var[$number_in_arr]}"
                        print_message $BLUE "Connecting to database '$selected_db'..."
                        connect_to_database "$selected_db"
                        break
                    else
                        print_message $RED "❌ Invalid number! Please choose a number from the list."
                    fi
                else
                    print_message $RED "❌ Please enter a valid positive number."
                fi
            done
        else
            print_message $YELLOW "Returning to main menu..."
            show_main_menu
        fi
    fi
}



connect_to_database() {
 if [ -z "$(ls -A "$DBMS_HOME" 2>/dev/null)" ]; then
        print_message $RED "No databases found!"
        if ask_yes_no "Do you want to create a database?"
        then
            create_database
        else
            print_message $YELLOW "Returning to main menu..."
            show_main_menu
        fi
    else

        var=($(ls -A "$DBMS_HOME"))
        print_message $GREEN "Avilable databases: ${#var[@]}"


        for (( i = 0; i < ${#var[@]}; i++ ))
        do
            print_message $GREEN "$((i+1)). ${var[$i]}"
        done
        echo

	while true; do
                echo -n "Enter the number of the database to connect: "
                read number

                if validate_positive_integer "$number"; then
                    number_in_arr=$((number - 1))
                    if [ "$number_in_arr" -ge 0 ] && [ "$number_in_arr" -lt ${#var[@]} ]; then
                        selected_db="${var[$number_in_arr]}"
			
                        cd "$DBMS_HOME/$selected_db"
			echo ""
                        print_message $BLUE "Connecting to database '$selected_db'..."
			echo ""
                        #source "$SCRIPT_DIR/DBmenu.sh"
			DBmenu $selected_db
			#show_database_menu "$selected_db"
			#cd ..

                    else
                        print_message $RED "❌ Invalid number! Please choose a number from the list."
                    fi
                fi
            done
fi
}

drop_database() {

if [ -z "$(ls -A "$DBMS_HOME" 2>/dev/null)" ]; then
        print_message $RED "No databases found!"
        if ask_yes_no "Do you want to create a database?"
        then
            create_database
        else
		echo
            print_message $YELLOW "Returning to main menu..."
		echo
		show_main_menu
        fi
    else

        var=($(ls -A "$DBMS_HOME"))
        print_message $GREEN "Avilable databases: ${#var[@]}"


        for (( i = 0; i < ${#var[@]}; i++ ))
        do
            print_message $GREEN "$((i+1)). ${var[$i]}"
        done
        echo

	while true; do
                echo -n "Enter the number of the database to drop (or 'back' to return): "
                read number
		if [ "$number" = "back" ]; then
			echo           	
		 print_message $YELLOW "Returning to main menu..."
                     echo
            	  show_main_menu
       		fi

                if validate_positive_integer "$number"; then
                    number_in_arr=$((number - 1))
                    if [ "$number_in_arr" -ge 0 ] && [ "$number_in_arr" -lt ${#var[@]} ]; then
                        selected_db="${var[$number_in_arr]}"
			
                       
                       echo ""    
                      print_message $YELLOW "⚠️  WARNING: This will permanently delete database '$selected_db' and all its tables!"
                      if ask_yes_no "Are you sure? (type 'yes' to confirm): "
                      then
                        echo ""
                        rm -rf "$DBMS_HOME/$selected_db"
				 if [ $? -eq 0 ]; then
                        print_message $GREEN "Database '$selected_db' dropped successfully!"
					show_main_menu
				 else 
			   print_message $RED "❌ Failed to delete database '$selected_db'"
				fi
		      else
                                    print_message $RED "❌ Operation cancelled."
                                    echo
                      fi
                      return
                    else
                        print_message $RED "❌ Invalid number! Please choose a number from the list."
                    fi
                fi
            done
fi
    
}

