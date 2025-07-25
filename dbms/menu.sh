show_main_menu() {
while true; do
print_message $CYAN ""
print_message $CYAN "╔══════════════════════════════════════════╗"
print_message $CYAN "║ ░▒▓█▓▒░      DBMS Main Menu      ░▒▓█▓▒░ ║" 
print_message $CYAN "╚══════════════════════════════════════════╝"
print_message $CYAN ""
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
 
		   drop_database                
		    break
                  ;;
            "Exit")
            print_message $GREEN "Goodbye! Thank you for using our DBMS."
             exit 0
                 ;;
            *)
            print_message $RED"✗ Error:Invalid option. Please select 1-5."
            echo
                  continue
                  ;;
            esac
           
        done
 done

}
create_database() {
    echo
print_message $BLUE "█▓▒░ CREATING DATABASES SYSTEM ░▒▓█"
    echo

    while true
    do
      read -p "Enter database name: " db_name
      if ! validate_name "$1" "database name"; then
            echo "Please try again with a valid name."
            echo ""
            continue
      fi
        
      if ! validate_database_unique "$1"; then
            echo "Please choose a different name."
            echo ""
            continue
      fi
        
      if mkdir -p "$DBMS_HOME/$1" 2>/dev/null
      then
            print_message $GREEN "✓ Database '$1' created successfully!"
            print_message $GREEN "✓ Location: $DBMS_HOME/$1"
            echo

            if ask_yes_no "Would you like to connect to this database now?"
            then
                print_message $YELLOW "Connecting to database '$1'..."
		        cd "$DBMS_HOME/$1"
                DBmenu "$1"
	   
            fi
               echo
               return
     else
            print_message $RED "✗ Failed to create database '$1'"
            echo
      fi
            

done
}

list_databases() {
    echo
print_message $BLUE "█▓▒░ LISTING DATABASES SYSTEM ░▒▓█"
    echo

    if [ ! -d "$DBMS_HOME" ] || [ -z "$(ls -A "$DBMS_HOME" 2>/dev/null)" ]
    then
        print_message $RED "✗ Error:No databases found!"
        echo
        if ask_yes_no "Do you want to create a database?"
        then
            create_database
        fi
        return
    fi

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
                echo -n "Enter the number of the database to connect (or 'back' to return):"
                read number
                if [ "$number" = "back" ]; then
                    return
                fi
                if validate_positive_integer "$number"; then
                    number_in_arr=$((number - 1))
                    if [ "$number_in_arr" -ge 0 ] && [ "$number_in_arr" -lt ${#var[@]} ]; then
                        selected_db="${var[$number_in_arr]}"
                        print_message $BLUE "Connecting to database '$selected_db'..."
                        connect_to_database "$selected_db"
                        break
                    else
                        print_message $RED "✗ Error:Invalid number! Please choose a number from the list."
                    fi
                else
                    print_message $RED "✗ Error:Please enter a valid positive number."
                fi
            done
        else
            print_message $YELLOW "Returning to main menu..."
            show_main_menu
        fi
    fi
}



connect_to_database() {
print_message $GREEN ""
print_message $GREEN "█▓▒░ CONNECTING TO DATABASE SYSTEM ░▒▓█"
print_message $GREEN ">>> ACCESSING: $1"
print_message $GREEN ">>> USER: $(whoami)@$(hostname)"
print_message $GREEN ">>> STATUS: Awaiting commands..."
print_message $GREEN ""

if [ ! -d "$DBMS_HOME" ] || [ -z "$(ls -A "$DBMS_HOME" 2>/dev/null)" ]
then
        print_message $RED "✗ Error:No databases found!"
        echo
        if ask_yes_no "Do you want to create a database?"
        then
            create_database

        fi
        return
    fi

        var=($(ls -A "$DBMS_HOME"))
        print_message $GREEN "Avilable databases: ${#var[@]}"


        for (( i = 0; i < ${#var[@]}; i++ ))
        do
            print_message $GREEN "$((i+1)). ${var[$i]}"
        done
        echo

	while true; do
                echo -n "Enter the number of the database to connect (or 'back' to return): "
                read number
                if [ "$number" = "back" ]; then
                       return
                fi
                    if validate_positive_integer "$number"; then
                    number_in_arr=$((number - 1))
                    if [ "$number_in_arr" -ge 0 ] && [ "$number_in_arr" -lt ${#var[@]} ]; then
                        selected_db="${var[$number_in_arr]}"
			
                        if ! cd "$DBMS_HOME/$selected_db" 2>/dev/null; then
                           print_message $RED "✗ Error: Cannot access database '$selected_db'"
                              echo
                             continue
                        fi
			            print_message $BLUE "Connected to database '$selected_db'"
                           echo
                           DBmenu "$selected_db"
                           return
                    else
                          print_message $RED "✗ Invalid number! Please choose a number from the list."
                          echo
                fi
            else
            print_message $RED "✗ Please enter a valid positive number."
            echo
        fi
    done
}

drop_database() {
    echo
print_message $BLUE "█▓▒░ DROP FROM DATABASES SYSTEM ░▒▓█"
    echo
if [ ! -d "$DBMS_HOME" ] || [ -z "$(ls -A "$DBMS_HOME" 2>/dev/null)" ]; then
        print_message $RED "✗ No databases found!"
        echo
        if ask_yes_no "Do you want to create a database?"; then
            create_database
        fi
        return
fi

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
			   print_message $RED "✗ Error: Failed to delete database '$selected_db'"
				fi
		      else
                                    print_message $RED "✗ Error:Operation cancelled."
                                    echo
                      fi
                      return
                    else
                        print_message $RED "✗ Error:Invalid number! Please choose a number from the list."
                    fi
                fi
            done
fi
    
}

drop_database() {
    echo
print_message $BLUE "█▓▒░ DROP FROM DATABASES SYSTEM ░▒▓█"
    echo
    
    if [ ! -d "$DBMS_HOME" ] || [ -z "$(ls -A "$DBMS_HOME" 2>/dev/null)" ]; then
        print_message $RED "✗ No databases found!"
        echo
        if ask_yes_no "Do you want to create a database?"; then
            create_database
        fi
        return
    fi

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
            return
        fi

        if validate_positive_integer "$number"; then
            local number_in_arr=$((number - 1))
            if [ "$number_in_arr" -ge 0 ] && [ "$number_in_arr" -lt ${#databases[@]} ]; then
                local selected_db="${databases[$number_in_arr]}"
                
                echo
                print_message $YELLOW "⚠️  WARNING: This will permanently delete database '$selected_db' and all its tables!"
                echo
                
                if ask_yes_no "Are you sure you want to drop database '$selected_db'?"; then
                    if rm -rf "$DBMS_HOME/$selected_db" 2>/dev/null; then
                        print_message $GREEN "✓ Database '$selected_db' dropped successfully!"
                        echo
                    else
                        print_message $RED "✗ Error: Failed to delete database '$selected_db'"
                        echo
                    fi
                else
                    print_message $YELLOW "Operation cancelled."
                    echo
                fi
                return
            else
                print_message $RED "✗ Invalid number! Please choose a number from the list."
                echo
            fi
        else
            print_message $RED "✗ Please enter a valid positive number."
            echo
        fi
    done
}