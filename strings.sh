#!/usr/bin/env bash

##
# Calculate and return a checksum for one string
# @param string $1 String
# @return string
# @returnStatus If first parameter named string is empty
# @returnStatus If checkum is empty or cksum methods returns in error
function checksum ()
{
    if [[ -z "$1" ]]; then
        return 1
    fi

    local CHECKSUM
    CHECKSUM="$(cksum <<<"$(trim "$1")" | awk '{print $1}')"
    if [[ $? -ne 0 || -z "$CHECKSUM" ]]; then
        return 1
    fi

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
# Print a string and apply on it a left padding
# @param string $1 String
# @param int $2 Pad length
# @param string $3 Padding char
# @return string
function printLeftPadding ()
{
    local STR="$1"
    declare -i PAD="$2"
    local CHR="$3"

    if [[ -z "${CHR}" ]]; then
        PAD+=${#STR}
        printf "%${PAD}s" "$STR"
    else
        if [[ ${PAD} -gt 1 ]]; then
            local PADDING=$(printf '%0.1s' "${CHR}"{1..500})
            printf '%*.*s' 0 $((${PAD} - 1)) "${PADDING}"
        fi
        echo -n " ${STR}"
    fi
}

##
# Print a string and apply on it a right padding
# @param string $1 String
# @param int $2 Pad length
# @param string $3 Padding char
# @return string
function printRightPadding ()
{
    local STR="$1"
    declare -i PAD="$2"
    local CHR="$3"

    if [[ -z "${CHR}" ]]; then
        PAD+=${#STR}
        printf "%-${PAD}s" "$STR"
    else
        echo -n "${STR} "
        if [[ ${PAD} -gt 1 ]]; then
            local PADDING=$(printf '%0.1s' "${CHR}"{1..500})
            printf '%*.*s' 0 $((${PAD} - 1)) "${PADDING}"
        fi
    fi
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