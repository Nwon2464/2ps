#!/bin/csh

source ../config/config.env

if ($#argv == 0) then
    echo "Error: No message provided." >&2
    exit 1
endif


set CURRENT_DATE = `date "+%Y-%m-%d %H:%M:%S"`

# Log the message with the timestamp
echo "[$CURRENT_DATE] $argv" >> $LOG_FILE
