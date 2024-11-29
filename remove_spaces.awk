#!/usr/bin/awk -f

# AWK script to remove unnecessary spaces in a CSV file
BEGIN {
    FS = ","; OFS = ","  # Define input and output field separators
}

{
    # Trim leading and trailing spaces for each field
    for (i = 1; i <= NF; i++) {
        gsub(/^ +| +$/, "", $i);  # Remove leading and trailing spaces
    }
    print $0;  # Print the cleaned line
}
