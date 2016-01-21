#!/usr/bin/env bash

##
# Computes the difference of arrays
#
# @example inputs "v1 v2 v3" "v1"
# @example return "v2 v3"
#
# @param stringableArray $1
# @param stringableArray $2
# @return stringableArray
function arrayDiff ()
{
    local ARRAY_1="$1"
    local ARRAY_2="$2"
    if [[ -z "$ARRAY_1" ]]; then
        echo "()"
        return
    elif [[ -z "$ARRAY_2" ]]; then
        echo "($ARRAY_1)"
        return
    fi
    IFS=' ' read -a ARRAY_1 <<< "$ARRAY_1"
    IFS=' ' read -a ARRAY_2 <<< "$ARRAY_2"

    declare -i SKIP
    local DIFFERENCE=()
    for I in ${ARRAY_1[@]}; do
        SKIP=0
        for J in ${ARRAY_2[@]}; do
            [[ "$I" == "$J" ]] && { SKIP=1; break; }
        done
        [[ "$SKIP" -eq 1 ]] || DIFFERENCE+=("$I")
    done

    echo "${DIFFERENCE[@]}"
}

##
# Searches the array for a given value and returns the corresponding key if successful
#
# @example inputs "v2" "v1 v2 v3"
# @example return "1"
#
# @param string $1
# @param stringableArray $2
# return int
function arraySearch ()
{
    local NEEDLE="$1"
    local HAYSTACK="$2"

    if [[ -z "$NEEDLE" ]] || [[ -z "$HAYSTACK" ]]; then
        return 1
    fi
    IFS=' ' read -a HAYSTACK <<< "$HAYSTACK"
    declare -i HAYSTACK_LENGTH="${#HAYSTACK[@]}"

    declare -i I
    for (( I=0; I < "$HAYSTACK_LENGTH"; I++ )); do
        if [[ "${HAYSTACK[$I]}" == ${NEEDLE} ]]; then
            echo -n "$I"
            return
        fi
    done

    return 1
}

##
# Check if a value is available in array
# @param string $1 Needle
# @param stringableArray $2 Haystack
# @return int O if found, 1 otherwise
function inArray ()
{
    local NEEDLE="$1"
    local HAYSTACK="$2"

    if [[ -z "$NEEDLE" ]] || [[ -z "$HAYSTACK" ]]; then
        return 1
    fi
    IFS=' ' read -a HAYSTACK <<< "$HAYSTACK"

    for VALUE in ${HAYSTACK[@]}; do
        if [[ "${VALUE}" == ${NEEDLE} ]]; then
            return 0
        fi
    done

    return 1
}

##
# Get printed array string with declare method and convert it in stringableArray
#
# @example input declare -A rv='([k]="v")'
# @example code
#   declare -A rv
#   rv[k]="v"
#   stringableArray "$(declare -p rv)"
# @example return ([k]=v)
#
# @param string $1 STRINGABLE_ARRAY
# @return string
function stringableArray ()
{
    local STRINGABLE_ARRAY="$1"

    # Remove declare -OPTIONS ='(
    STRINGABLE_ARRAY="${STRINGABLE_ARRAY#*(}"
    # Remove )'
    STRINGABLE_ARRAY="${STRINGABLE_ARRAY%)*}"
    # Remove escaping of single quote (') by declare function
    STRINGABLE_ARRAY="${STRINGABLE_ARRAY//\\\'\'/}"

    echo -n "(${STRINGABLE_ARRAY})"
}