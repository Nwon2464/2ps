#!/usr/bin/awk -f

# AWK script to process the DATES column (5th column)
BEGIN {
    FS = ","; OFS = ","  # Define input and output field separators
}

NR == 1 {
    # Print header as is
    print $0;
    next;
}

{

    print "Processing line:" NR;  # Print the current line number
    original_date = $5;  # Store the original DATES value

    # Normalize date format to YYYY-MM-DD
    # Replace space with ""
    # gsub(/\s/, "", $5); 
    # remove leading and trailing spaces first. 
    gsub(/^[ \t]+|[ \t]+$/, "", $5);
    print "SSS" $5 length($5) "$$$$"
    if (length($5) == 10) {
print "before" $5

    gsub(/[ \t]+|[^0-9]/, "-", $5);
print "after" $5
        # this is to repace any non-numeric character with hypen but why it doesn't cover space ? 
        # gsub(/[^0-9]/, "-", $5);  # Replace spaces and any non-numeric character with a hyphen
        $5 = substr($5, 1, 4) "-" substr($5, 6, 2) "-" substr($5, 9, 2);
    } else {
        # If the length is incorrect, set it to a placeholder date (optional)
        $5 = "0000-00-00";
    }

    # Log changes if the date was modified
    if (original_date != $5) {
        print "Line " NR ": Corrected DATES from \"" original_date "\" to \"" $5 "\"" > "dates_column_changes.log";
    }


    # Print the cleaned record
    print $1, $2, $3, $4, $5;
}
