#!/usr/bin/env bash

# Use BC by default to manipulate string. If BC is not available, used pure bash
declare -r -i BP_BC="$(if [[ -z "$(type -p bc)" ]]; then echo 0; else echo 1; fi)"
declare -r BP_INT_TYPE="integer"
declare -r BP_FLOAT_TYPE="float"
declare -r BP_UNKNOWN_TYPE="unknown"

##
# Finds whether the type of a variable is float
# @param string $1
# @return int If is a float 1, 0 otherwise
function isFloat ()
{
    declare -i RES=0
    if [[ -z "$1" ]]; then
        return 1
    fi

    if [[ "$1" =~ ^[-+]?[0-9]+\.[0-9]+$ ]]; then
        RES=1
    fi
    echo -n ${RES}

    if [[ ${RES} -eq 0 ]]; then
        return 1
    fi
}

##
# Find whether the type of a variable is integer
# @param string $1
# @return int If is a float then 1, 0 otherwise
function isInt ()
{
    declare -i RES=0
    if [[ -z "$1" ]]; then
        return 1
    fi

    if [[ "$1" =~ ^[-+]?[0-9]+$ ]]; then
        RES=1
    fi
    echo -n ${RES}

    if [[ ${RES} -eq 0 ]]; then
        return 1
    fi
}

##
# Finds whether a variable is a number or a numeric string
# @param string $1
# @return int If is a numeric then 1, 0 otherwise
function isNumeric ()
{
    declare -i RES=0
    if [[ 1 -eq $(isFloat "$1") || 1 -eq $(isInt "$1") ]]; then
         RES=1
    fi
    echo -n ${RES}

    if [[ ${RES} -eq 0 ]]; then
        return 1
    fi
}

##
# First float value is greater than the second ?
# @param float $1
# @param float $2
# @return int If $1 is greater than $2 then 1, 0 otherwise
function floatGreaterThan ()
{
    local VAR_1="$1"
    local RES_1
    RES_1=$(numericType "$VAR_1")
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    local VAR_2="$2"
    local RES_2
    RES_2=$(numericType "$VAR_2")
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    declare -i RES=0
    if [[ "$BP_BC" -eq 1 ]]; then
        RES=$(echo "${VAR_1} > ${VAR_2}" | bc)
    else
        if [[ "$RES_1" == "${BP_INT_TYPE}" ]]; then
            VAR_1="${VAR_1}.0"
        fi
        if [[ "$RES_2" == "${BP_INT_TYPE}" ]]; then
            VAR_2="${VAR_2}.0"
        fi
        if (( ${VAR_1%%.*} > ${VAR_2%%.*} || ( ${VAR_1%%.*} == ${VAR_2%%.*} && ${VAR_1##*.} > ${VAR_2##*.} ) )) ; then
            RES=1
        fi
    fi
    echo -n ${RES}

    if [[ ${RES} -eq 0 ]]; then
        return 1
    fi
}

##
# First float value is lower than the second ?
# @param float $1
# @param float $2
# @return int If $1 is lower than $2 then 1, 0 otherwise
function floatLowerThan ()
{
    declare -i RES

    RES=$(floatGreaterThan "$2" "$1")
    if [[ $? -ne 0 ]]; then
        echo -n ${RES}
        return 1
    fi

    echo -n ${RES}
}

##
# Get the type of a numeric variable
#
# Possible values for the returned string are:
# - "float" via constant named BP_UNKNOWN_TYPE
# - "int" via constant named BP_UNKNOWN_TYPE
# - "unknown" via constant named BP_UNKNOWN_TYPE
#
# @param stringableNumeric $1
# @return string
function numericType ()
{
    if [[ 1 -eq $(isFloat "$1") ]]; then
        echo -n "${BP_FLOAT_TYPE}"
    elif [[ 1 -eq $(isInt "$1") ]]; then
        echo -n "${BP_INT_TYPE}"
    else
        echo -n "${BP_UNKNOWN_TYPE}"
        return 1
    fi
}