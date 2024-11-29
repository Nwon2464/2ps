#!/usr/bin/awk -f

# AWK script to process the AMOUNT column (4th column)
BEGIN {
    FS = ","; OFS = ","  # Define input and output field separators
}

NR == 1 {
    # Print header as is
    print $0;
    next;
}

{
    original_amount = $4;  # Store the original AMOUNT
    # Check if the data is valid
    if ($4 == "NaN" || $4 == "NULL" || $4 ~ /^-/) {
        $4 = 0;  # Invalid data
        printf "Line %d: Changed invalid AMOUNT \"%s\" to 0\n", NR, original_amount >> "amount_column_changes.log";
    } else {
        # Convert valid data to a double with 5 decimal places
        $4 = sprintf("%.5f", $4);
        if (original_amount != $4) {
            printf "Line %d: Updated AMOUNT from \"%s\" to \"%s\"\n", NR, original_amount, $4 >> "amount_column_changes.log";
        }
    }

    # Print the cleaned record
    print $1, $2, $3, $4, $5;
}
