#! /bin/csh 

source ../config/config.env

set CURRENT_DATE = `date "+%Y-%m-%d %H:%M:%S"`
echo "----------------------------------------" > $LOG_FILE
echo "Process started at: '$CURRENT_DATE'" >> $LOG_FILE

# -----------------------------------------------------------------------------
# Step 1: Validate Input File
# -----------------------------------------------------------------------------
./log_message.csh "Step 1: Validating input file: $INPUT_FILE"
echo "${cyan}Step 1: Validating input file: $INPUT_FILE${end}"


./error_with_log.csh $INPUT_FILE 
if ($status != 0 ) then
    exit 1
endif

./log_message.csh "Input file '$INPUT_FILE' exists."
echo "Input file ${green} $INPUT_FILE ${end} exists."


# -----------------------------------------------------------------------------
# Step 2: Preprocessing
# -----------------------------------------------------------------------------
# Removes spaces around commas,leading/trailing spaces/tabs and remain only one header 

./log_message.csh "Step 2: Starting preprocessing"
echo "${cyan}Step 2: Starting preprocessing${end}"

grep -v '^SQL>' "$INPUT_FILE" | \
grep -v 'rows selected' | \
grep -v '^[-]\{4,\}' | \
grep -v '^[[:space:]]*$' | \
sed 's/[[:space:]]*,[[:space:]]*/,/g; s/^[[:space:]]*//; s/[[:space:]]*$//' | awk -f preprocess.awk > "$PREPROCESSED_FILE"

if ($status != 0) then
    echo "Preprocessing failed"
    ./error_with_log.csh "Preprocessing failed."
    exit 1
endif

./log_message.csh "Preprocessing completed successfully. Output file: '$PREPROCESSED_FILE'"
echo "Preprocessing completed successfully. Output file: ${green}$PREPROCESSED_FILE${end}"

# -----------------------------------------------------------------------------
# Step 3: Sorting and Removing Duplicates
# -----------------------------------------------------------------------------

./log_message.csh "Step 3 : Sorting and removing duplicates."
echo "${cyan}Step 3: Sorting and removing duplicates.${end}"


# Extract the first line and then sort the rest
awk 'NR==1 {print; next} {print | "sort -u"}' "$PREPROCESSED_FILE" > "$SORTED_UNIQUE_FILE"

if ($status != 0) then
    echo "Sorting and removing duplicates failed."
    ./error_with_log.csh "Sorting and removing duplicates failed."
endif

./log_message.csh "Sorting and removing duplicates completed successfully. Output file: '$SORTED_UNIQUE_FILE'"
echo "Sorting and removing duplicates completed successfully. Output file: ${green}$SORTED_UNIQUE_FILE${end}"

# -----------------------------------------------------------------------------
# Step 4: Normalizing
# -----------------------------------------------------------------------------

./log_message.csh "Step 4: Starting normalization."
echo "${cyan}Step 4: Starting normalization.${end}"

awk -f normalize.awk "$SORTED_UNIQUE_FILE" > "$NORMALIZED_FILE"

if ($status != 0) then
    ./error_with_log.csh "Normalization failed."
    echo "Normalization failed."
endif

./log_message.csh "Normalization completed successfully. Output file: '$NORMALIZED_FILE'"
echo "Normalization completed successfully. Output file: ${green}$NORMALIZED_FILE${end}"


# -----------------------------------------------------------------------------
# Step 5: Formatting Amount
# -----------------------------------------------------------------------------

./log_message.csh "Step 5: Starting formatting amounts."
echo "${cyan}Step 5: Starting formatting amounts.${end}"

awk -f format_amount.awk "$NORMALIZED_FILE" > "$FORMATTING_AMOUNT_FILE"

if ($status != 0) then
    echo "Formatting amounts failed."
    ./error_with_log.csh "Formatting amounts failed."
endif

./log_message.csh "Formatting amounts completed successfully. Output file: '$FORMATTING_AMOUNT_FILE'"
echo "Formatting amounts completed successfully. Output file: ${green}$FORMATTING_AMOUNT_FILE${end}"

# -----------------------------------------------------------------------------
# Step 6: Categorizing
# -----------------------------------------------------------------------------
./log_message.csh "Step 6: Starting categorization."
echo "${cyan}Step 6: Starting categorization.${end}"

awk -f add_category.awk "$FORMATTING_AMOUNT_FILE" > "$CATEGORIZED_FILE"

if ($status != 0) then
    echo "Categorization failed."
    ./error_with_log.csh "Categorization failed."
endif

./log_message.csh "Categorization completed successfully. Output file: '$CATEGORIZED_FILE'"
echo "Categorization completed successfully. Output file: ${green}$CATEGORIZED_FILE${end}"

# -----------------------------------------------------------------------------
# Finalizing
# -----------------------------------------------------------------------------

cp $CATEGORIZED_FILE $FINAL_FILE
mv $FINAL_FILE ../scripts/

set END_DATE = `date "+%Y-%m-%d %H:%M:%S"`
./log_message.csh "Process completed at: '$END_DATE'"
echo "Process completed at: $END_DATE"
echo "----------------------------------------" >> $LOG_FILE
