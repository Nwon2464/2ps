#! /bin/csh

source ../config/config.env

if (! -e "$1") then
    set CURRENT_DATE = `date "+%Y-%m-%d %H:%M:%S"`
    # Log the error message with the timestamp
    echo "[$CURRENT_DATE] ERROR: $1" >> $LOG_FILE
    echo "${red}Input file '$1' does not exist. Terminating script.${end}"
    exit 1
else
    exit 0
endif
