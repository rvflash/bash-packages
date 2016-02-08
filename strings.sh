#!/usr/bin/env bash

declare -r BP_STRINGS_WRK_DIR="/tmp"

##
# Calculate and return a checksum for one string
# @param string $1 String
# @param string $2 PathToWorkspace with default value from constant named BP_STRINGS_WRK_DIR [optional]
# @return string
# @returnStatus If first parameter named string is empty
# @returnStatus If checkum is empty or cksum methods returns in error
function checksum ()
{
    local STR="$1"
    if [[ -z "$STR" ]]; then
        return 1
    fi
    local WRK_DIR="$2"
    if [[ -z "$WRK_DIR" ]]; then
        WRK_DIR="$BP_STRINGS_WRK_DIR"
    fi

    # Create temporary file to apply checksum function on it
    local CHECKSUM_FILE="${WRK_DIR}/${RANDOM}.crc"
    echo -n "$(trim "$STR")" > "$CHECKSUM_FILE"

    local CHECKSUM
    CHECKSUM="$(cksum "$CHECKSUM_FILE" | awk '{print $1}')"
    if [[ $? -ne 0 || -z "$CHECKSUM" ]]; then
        return 1
    fi

    # Clean workspace
    rm -f "$CHECKSUM_FILE"

    echo -n "$CHECKSUM"
}

##
# Determine whether a variable is empty
# The following things are considered to be empty:
#
#     "" (an empty string)
#     0 (0 as an integer or string)
#     0.0 (0 as a float)
#     FALSE
#     array() (an empty array)
#
# @returnStatus 1 If empty, 0 otherwise
function isEmpty ()
{
    local VAR="$1"
    if [[ -z "${VAR}" || "${VAR}" == 0 || "${VAR}" == "0.0" || "${VAR}" == false || "${VAR}" =~ ^\(([[:space:]]*)?\)*$ ]]; then
        return 0
    fi

    return 1
}

##
# This function returns a string with whitespace (or other characters) stripped from the beginning and end of str
# @param string $1 String
# @param string $2 Character to mask [optional]
# @return string
function trim ()
{
    local STR="$1"
    if [[ -z "$STR" ]]; then
        return 0
    fi

    local MASK="$2"
    if [[ -n "$MASK" ]]; then
        # Escape special chars
        MASK=$( echo "$MASK" | sed -e 's/[]\/$*.^|[]/\\&/g' )
        # Remove characters to mask
        STR=$( echo "$STR" | sed -e "s/^[[:space:]]*[${MASK}]*//" -e "s/[${MASK}]*[[:space:]]*$//" )
    fi

    echo -n "$STR" | sed -e "s/^[[:space:]]*//" -e "s/[[:space:]]*$//"
}