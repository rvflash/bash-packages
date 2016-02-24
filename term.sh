#!/usr/bin/env bash

declare -r BP_TERM_ERROR="An error occured"

##
# @example Are you sure ? [Y/N]
# @codeCoverageIgnore
# @param string $1 Message
# @param string $2 Default message to add after confirm request [optional]
# @returnStatus 0 I answer is YES
# @returnStatus 1 I answer is NO
function confirm ()
{
    local DEFAULT_MESSAGE="$2"

    local CONFIRM
    while read -e -p "$1 ${DEFAULT_MESSAGE}? " CONFIRM; do
        if [[ "$CONFIRM" == [Yy] || "$CONFIRM" == [Yy][Ee][Ss] ]]; then
            return 0
        elif [[ "$CONFIRM" == [Nn] || "$CONFIRM" == [Nn][Oo] ]]; then
            return 1
        fi
    done
}

##
# Ask anything to user and get his response
# @codeCoverageIgnore
# @param string $1 Message
# @param int $2 If 1 or undefined, a response is required, 0 otherwise [optional]
# @param string $3 Mandatory text [optional]
# return string
function dialog ()
{
    local MESSAGE="$1"
    local MANDATORY="$2"
    if [[ -z "$MANDATORY" || "$MANDATORY" -ne 0 ]]; then
        MANDATORY=1
    fi
    local MANDATORY_MESSAGE="$3"

    local COUNTER=0
    local MANDATORY_FIELD
    local RESPONSE
    while [[ "$MANDATORY" -ne -1 ]]; do
        if [[ "$MANDATORY" -eq 1 && "$COUNTER" -gt 0 && -n "$MANDATORY_MESSAGE" ]]; then
            MANDATORY_FIELD=" ${MANDATORY_MESSAGE}"
        fi
        read -e -p "${MESSAGE}${MANDATORY_FIELD}: " RESPONSE
        if [[ -n "$RESPONSE" ]] || [[ "$MANDATORY" -eq 0 ]]; then
            echo "$RESPONSE"
            MANDATORY=-1
        fi
        ((COUNTER++))
    done
}

##
# Print a progress bar
#
# @example
#    Upload  [++++++++++++++++----] 70%
#
# @param string $1 Name
# @param int $2 Step
# @param int $3 Max
# @param string $4 Error, default "An error occured". Printed if the max value is lower or equals to 0
# @param int $5 With, default 20
# @param string $6 CharEmpty, default -
# @param string $7 CharFilled, default +
# @return string
# @returnStatus 1 If first parameter named jobName is empty
# @returnStatus 1 If third parameter named Max is negative (an error occured)
function progressBar ()
{
    local NAME="$1"
    if [[ -z "${NAME}" ]]; then
        return 1
    fi
    declare -i STEP="$2"
    declare -i MAX="$3"
    local ERROR="$4"
    if [[ -z "${ERROR}" ]]; then
        ERROR="${BP_TERM_ERROR}"
    fi
    if [[ ${MAX} -le 0 ]]; then
        echo -e "${ERROR}"
        return 1
    fi
    declare -i WIDTH="$5"
    if [[ ${WIDTH} -eq 0 ]]; then
        WIDTH=20
    fi
    local CHAR_EMPTY="$6"
    if [[ -z "${CHAR_EMPTY}" ]]; then
        CHAR_EMPTY="-"
    fi
    local CHAR_FILLED="$7"
    if [[ -z "${CHAR_FILLED}" ]]; then
        CHAR_FILLED="+"
    fi

    declare -i PERCENT=0
    declare -i PROGRESS=0
    if [[ ${STEP} -gt 0 ]]; then
        PERCENT=$((100*${STEP}/${MAX}))
        PROGRESS=$((${WIDTH}*${STEP}/${MAX}))
        if [[ ${PROGRESS} -gt ${WIDTH} ]]; then
            PROGRESS=${WIDTH}
        fi
    fi
    declare -i EMPTY=$((${PROGRESS}-${WIDTH}))

    # Output to screen
    local STR_FILLED=$(printf "%${PROGRESS}s" | tr " " "${CHAR_FILLED}")
    local STR_EMPTY=$(printf "%${EMPTY}s" | tr " " "${CHAR_EMPTY}")
    printf "\r%s [%s%s] %d%% " "${NAME}" "${STR_FILLED}" "${STR_EMPTY}" "${PERCENT}"

    # Job done
    if [[ ${STEP} -ge ${MAX} ]]; then
        echo
    fi
}

##
# Get width or height or both of a terminal window
#
# @example return width
# @example return width height
#
# @param string $1 Type width or height [optional]
# @return int or arrayToString
function windowSize ()
{
    local TYPE="$1"
    local SIZE
    SIZE=$(stty size 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    case "$TYPE" in
        "width" ) echo -n "${SIZE##* }" ;;
        "height") echo -n "${SIZE%% *}" ;;
        *       ) echo -n "(${SIZE})" ;;
    esac
}