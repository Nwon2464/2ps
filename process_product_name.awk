#!/usr/bin/awk -f

# AWK script to process the PRODUCT_NAME column
BEGIN {
    FS = ","; OFS = ","  # Define input and output field separators
}

NR == 1 {
    # Print header as is
    print $0;
    next;
}

{
    original_product_name = $3;  # Store the original PRODUCT_NAME
    gsub(/[^a-zA-Z ]/, "", $3);  # Remove non-alphabetic characters from PRODUCT_NAME

    # If the name was changed, log the change
    if (original_product_name != $3) {
        printf "Line %d: Changed PRODUCT_NAME from \"%s\" to \"%s\"\n", NR, original_product_name, $3 >> "product_name_changes.log";
    }

    # Print the cleaned record
    print $1, $2, $3, $4, $5;
}