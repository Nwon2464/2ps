#!/bin/csh

# Function to display error and exit
# alias error_exit 'echo \!* >&2; exit 1'

# # Prompt user for output filenames with defaults
# echo -n "Enter the desired filename for valid records (e.g., valid_records.csv): "
# set valid_records_filename = "$<"
# if ("$valid_records_filename" == "") then
#     set valid_records_filename = "valid_records.csv"
#     echo "No input provided. Using default filename: $valid_records_filename"
# endif

# echo -n "Enter the desired filename for data changes log (e.g., data_changes.log): "
# set data_changes_filename = "$<"
# if ("$data_changes_filename" == "") then
#     set data_changes_filename = "data_changes.log"
#     echo "No input provided. Using default filename: $data_changes_filename"
# endif

# # Check if spool.csv exists
# if (! -e spool.csv) then
#     echo "Error: Could not open file spool.csv" >&2
#     exit 1
# endif

# echo "Opened file spool.csv"


# Input, intermediate, and output file names
set input_file = "spool.csv"
set temp_file = "cleaned_spool_temp.csv"
set cleaned_file = "cleaned_spool.csv"
set output_file = "final_processed_cleaned_spool.csv"

# Check if the input file exists
if (! -e $input_file) then
    echo "Error: Input file $input_file not found!" >&2
    exit 1
endif


#!/bin/csh

# Input, intermediate, and output file names
set input_file = "spool.csv"
set temp_file = "cleaned_spool_temp.csv"
set cleaned_file = "cleaned_spool.csv"
set output_file = "final_processed_cleaned_spool.csv"

# Check if the input file exists
if (! -e $input_file) then
    echo "Error: Input file $input_file not found!" >&2
    exit 1
endif

# trim line  
# remove spaces, remove unncessary rows
sed '1,2d; 4d;' $input_file | head -n -4 > $temp_file


# write a gsub for removing leading and trailing spaces
########################################################################################
# # Step 2: Remove leading and trailing spaces
# gsub(/^[ \t]+|[ \t]+$/, "", $5);
awk -f remove_spaces.awk $temp_file > $cleaned_file
# rm $temp_file  # Cleanup intermediate file

# # Inform the user
# echo "leading and trailing spaces removed and cleaned file saved to $cleaned_file"

# # remove any leading or trailing non-alphabetic characters 
awk -f process_product_name.awk $cleaned_file > f$output_file
# # invalid number 
awk -f process_amount_column.awk f$output_file > ff$output_file
########################################################################################

awk -f process_dates_column.awk ff$output_file > f$input_file

# invalid integer

# invalid string 

# isEmpty 

# invalid format 

# invalid double 







