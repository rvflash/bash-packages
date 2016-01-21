#!/usr/bin/env bash

##
# Calculate and return a checksum for one string
# @param string $1
# @return string
function checksum ()
{
    local WRK_DIR="$2"
    if [[ -z "$WRK_DIR" ]]; then
        WRK_DIR='/tmp/'
    fi
    local CHECKSUM_FILE="${WRK_DIR}${RANDOM}.crc"
    echo -n "$1" > "$CHECKSUM_FILE"

    local CHECKSUM
    CHECKSUM=$(cksum "$CHECKSUM_FILE" | awk '{print $1}')
    if [[ $? -ne 0 || -z "$CHECKSUM" ]]; then
        return 1
    fi

    rm -f "$CHECKSUM_FILE"
    echo -n "$CHECKSUM"
}

##
# Remove leading and trailing whitespace
# @param string $1
# @return string
function trim ()
{
    echo "$1" | sed -e "s/^[[:space:]]*//" -e "s/[[:space:]]*$//"
}