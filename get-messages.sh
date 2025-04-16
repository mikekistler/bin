#!/bin/bash

# Retrieve the breaking changes messages from the log file passed as an argument
# Usage: ./get-messages.sh <log_file>
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <log_file>"
    exit 1
fi
log_file="$1"
if [ ! -f "$log_file" ]; then
    echo "File not found!"
    exit 1
fi
# Extract the breaking changes messages from the log file
# The messages appear after a line containing "---- Full list of messages ----" up to
# the next line containing "---- End of full list of messages ----"
awk '/---- Full list of messages ----/{flag=1;next}/---- End of full list of messages ----/{flag=0}flag' "$log_file" | \
# Remove the timestamp (a string ending in "Z") from each line
sed -E 's/^[0-9:.T-]+Z //g' | \
# Remove trailing commas where they are followed by a closing bracket (possibly on a new line)
sed -e ':a' -e 'N' -e '$!ba' -e 's/},\([[:space:]]*\)]/}\1]/g' | \
# At this point, the messages are in the format of a JSON array.
# Discard all the messages that contain "level" of "Info"
jq -r '.[] | select(.level != "Info")' | \
# Extract the "level", "code", and "message" field from each message and print on a single line
jq -r '"\(.level) \(.code) \(.message)"'
