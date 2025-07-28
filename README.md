# Simple Database Management System (DBMS)

A command-line interface (CLI) based Database Management System implemented in Bash scripting language that enables users to store and retrieve data from the hard disk using a file-based storage system.

## 🎯 Project Overview

This DBMS provides a complete database solution with support for multiple databases, tables, and standard database operations. It uses the file system as storage backend, where databases are stored as directories and tables as files within those directories.

## ✨ Key Features

### Main Menu Operations
- **Create Database**: Create new database instances
- **List Databases**: View all available databases
- **Connect to Database**: Access specific database for operations
- **Drop Database**: Delete entire database and all its contents

### Database Menu Operations
- **Create Table**: Define new tables with columns and data types
- **List Tables**: View all tables in current database
- **Drop Table**: Remove tables and all associated data
- **Insert into Table**: Add new records to tables
- **Select from Table**: Query and display table data
- **Delete from Table**: Remove specific records or all records
- **Update Table**: Modify existing records

### Advanced Features
- **Primary Key Support**: Automatic primary key validation and uniqueness checking
- **Data Type Validation**: Support for String, Integer, and Boolean data types
- **Interactive Menus**: User-friendly CLI with numbered menu options
- **Error Handling**: Detailed error messages and graceful error recovery
- **Data Integrity**: Ensures data consistency and prevents corruption

## 🏗️ System Architecture

```
DBMS Project Structure:
├── main.sh              # Main entry point and initialization
├── menu.sh              # Main menu operations (database level)
├── DBmenu.sh            # Database menu operations (table level)
├── DBmenu2.sh           # Extended table operations (select, delete, update)
├── validation.sh        # Input validation and data integrity functions
└── dbms_data/          # Data storage directory
    ├── database1/      # Individual database directory
    │   ├── table1.meta # Table metadata (schema definition)
    │   ├── table1.data # Table data (actual records)
    │   ├── table2.meta
    │   └── table2.data
    └── database2/
        └── ...
```

### File Structure Explanation

- **`.meta` files**: Store table schema information (column names, data types, constraints)
- **`.data` files**: Store actual table records in colon-separated format
- **Database directories**: Each database is a separate directory containing its tables

## 🚀 Installation & Setup

### Installation Steps

1. **Clone or download the project files**
   ```bash
   # Ensure all files are in the same directory
   ls -la
   # Should show: main.sh, menu.sh, DBmenu.sh, DBmenu2.sh, validation.sh
   ```

2. **Make scripts executable**
   ```bash
   chmod +x main.sh
   chmod +x menu.sh
   chmod +x DBmenu.sh
   chmod +x DBmenu2.sh
   chmod +x validation.sh
   ```

3. **Run the application**
   ```bash
   ./main.sh
   ```


### Example Workflow

```bash
# 1. Start DBMS
./main.sh

# 2. Create database "company"


# 3. Connect to database


# 4. Create employees table

# 5. Insert employee record


# 6. View all records


## 📊 Data Types

The DBMS supports three primary data types:

| Data Type | Description | Example Values | Validation |
|-----------|-------------|----------------|------------|
| `string` | Text data | "John Doe", "Manager" | Max 100 chars, no special chars |
| `int` | Integer numbers | 123, -456, 0 | 32-bit signed integers |
| `boolean` | True/false values | true, false, 0, 1 | Case-insensitive |

## 🛡️ Data Validation

### Input Validation Rules
- **Names**: Must start with letter, contain only letters, numbers, underscores
- **Primary Keys**: Must be unique within table
- **Data Types**: Strictly enforced based on column definition
- **File Safety**: Prevents injection of dangerous characters

### Error Handling
- Clear error messages for invalid inputs
- Graceful recovery from file system errors
- Prevention of data corruption through validation

## 🎨 User Interface Features

### Menu System
- **Numbered Options**: Easy selection with numeric input
- **Back Navigation**: Return to previous menus with 'back' option
- **Exit Options**: Clean exit from any menu level
- **Clear Formatting**: Color-coded messages and structured display

### Display Features
- **Formatted Tables**: Proper column alignment and borders
- **Status Messages**: Success/error indicators with colors
- **Progress Feedback**: Confirmation of operations
- **Interactive Prompts**: User-friendly input requests

## 🔧 Technical Implementation

The project is a simplified Bash-based DBMS that uses flat files for storage. It mimics basic relational database features using `.meta` and `.data` files for schema and records.

---

## 📝 File Formats

### 📁 Meta File Format (`.meta`)
Defines the schema for a table. Each line describes a column with its name, data type, and constraints.

```
column_name:data_type:constraint
id:int:PRIMARY_KEY
name:string:NONE
salary:int:NONE
```

### 📄 Data File Format (`.data`)
Stores actual records in the table. Each value is separated by colons, and the first line is a header matching the schema.

```
id:name:salary
1:John Doe:50000
2:Jane Smith:60000
```

---

## 👥 Project Information

**Created by**: hager tarek
**Course**: bash scripting
```

---