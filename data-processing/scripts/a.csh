#! /bin/csh
# Automation for database table migration
source ../config/config.env

################################################################
# Step 1: Spool the database table to a CSV file
echo "Starting the database table migration process..."
set sqlplus_path = "/mnt/c/app/np3-0/product/21c/dbhomeXE/bin/sqlplus.exe"

# Prompt for the table name
echo -n "Enter the table name to query: "
set table_name = $<

# Ensure the table name is valid
if ("$table_name" == "") then
    echo "Error: Table name cannot be empty."
    exit 1
endif


echo "Running SQL*plus for table '$table_name'..."

$sqlplus_path @db_credentials.txt <<EOF
SET COLSEP ','
SET PAGESIZE 10
SET HEADING ON
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
SPOOL spool.csv
SELECT * FROM $table_name;
SPOOL OFF;
EXIT;
EOF

echo "Spool completed. Output saved to 'spool.csv'."
mv ./spool.csv ../input


#################################################################
echo "#################################################################"
echo "Running automation script..."
set automate_script = $process_script
source $automate_script
if ($status != 0) then
    echo "Automation script failed. Exiting."
    exit 1
else
    echo "Automation script executed successfully."
    echo "#################################################################"
endif

#################################################################
# Step 3: Getting .csv file in a current directory(assuming only one spool.csv file exists).
# exclude spool.csv
set output_file = `ls | grep ".csv" | grep -v "spool.csv"`
if ("$output_file" == "") then
    echo "Error: No CSV file detected. Ensure the automation program outputs a CSV file."
    exit 1
endif

echo "Detected output file: $output_file"


# #################################################################
# Step 4: Create .ctl file for SQL*Loader
# Prompt for the name of the .ctl file to be created
echo -n "Enter the name for the .ctl file to be created:  (e.g., work.ctl):"
set ctl_file = $<
echo -n "Enter the new table name: "
set new_table_name = $<
echo "Be sure to make $new_table_name table in the database before running the script"

# Ensure the input is valid
if ("$ctl_file" == "") then
    echo "Error: .ctl file name cannot be empty."
    exit 1
endif

echo "Creating .ctl file '$ctl_file'..."
echo "Table name is: '$new_table_name'..."

cat > $ctl_file <<EOL
LOAD DATA
INFILE '$output_file'
INTO TABLE $new_table_name
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(id, product_id, product_name, amount, dates, category)
EOL

set sqlldr_path = $loader_path
$sqlldr_path "C##test/d72dadad@XE" control="$ctl_file"
