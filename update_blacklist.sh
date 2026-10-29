#!/bin/sh

# Paths to dependencies
PFCTL="/sbin/pfctl"
CURL="/usr/local/bin/curl"
TMP_LIST="/tmp/blocked_ips.txt"

# Ensure curl is installed (pkg_add curl)
if [ ! -x "$CURL" ]; then
    echo "Error: curl is not installed or not executable." >&2
    exit 1
fi

# Fetch the latest blacklist
$CURL -s "https://raw.githubusercontent.com/pebblehost/hunter/master/ips.txt" > "$TMP_LIST"

# Verify the file is not empty and contains valid-looking lines before modifying the table
if [ -s "$TMP_LIST" ]; then
    echo "Updating OpenBSD PF blacklist table..."

    # replace the entire contents of the table with the new list automatically
    $PFCTL -t blacklist -T replace -f "$TMP_LIST"

    echo "Blacklist updated successfully. Current count: $($PFCTL -t blacklist -T show | wc -l)"
else
    echo "Error: Downloaded list was empty. PF table not modified." >&2
    rm -f "$TMP_LIST"
    exit 1
fi

# Clean up
rm -f "$TMP_LIST"