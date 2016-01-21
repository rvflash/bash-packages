#!/usr/bin/env bash

declare -A BP_INCLUDE_FILE

##
# The include statement includes and evaluates the specified file.
# @param string $1 File
function include ()
{
    local FILE_PATH="$(realpath "$1")"
    if [[ $? -ne 0 || ! -f "$FILE_PATH" ]]; then
        echo "No such file or directory"
        return  1
    fi

    BP_INCLUDE_FILE["$FILE_PATH"]=1
    source "$FILE_PATH"
}

##
# The include_once statement includes and evaluates the specified file during the execution of the script.
# This is a behavior similar to the include statement, with the only difference being that if the code from a file
# has already been included, it will not be included again, and include_once returns TRUE.
# As the name suggests, the file will be included just once.
# @param string $1 File
function includeOnce ()
{
    local FILE_PATH="$(realpath "$1")"
    if [[ -z "${BP_INCLUDE_FILE["$FILE_PATH"]}" ]]; then
        include "$1"
        if [[ $? -ne 0 ]]; then
            return 1
        fi
    fi
}

##
# Returns canonicalized absolute pathname
# Expands all symbolic links and resolves references to '/./', '/../' and extra '/' characters in the input path
# @param string $1 path
# @return string
function realpath ()
{
    local DEST_PATH="$1"
    local DEST_FILE="$(basename "$DEST_PATH")"
    local DEST_DIR="$(dirname "$DEST_PATH")"
    local SOURCE_DIR="$(fullDirname "$0")"

    if [[ "$DEST_PATH" == "."* ]]; then
        # ../test.sh or ./test.sh
        DEST_PATH="${SOURCE_DIR}/${DEST_DIR}/${DEST_FILE}"
    elif [[ "$DEST_PATH" != "/"* ]]; then
        # test.sh
        DEST_PATH="${SOURCE_DIR}/${DEST_DIR}/${DEST_FILE}"
    fi

    DEST_DIR="$(fullDirname "$DEST_PATH")"
    if [[ -z "$DEST_DIR" ]]; then
        return 1
    fi

    echo "${DEST_DIR}/${DEST_FILE}"
}

##
# Returns the complete directory's path
# @param string $1 Filepath
# @return string
function fullDirname ()
{
    echo -n "$( cd "$(dirname "$1")"  2>/dev/null && pwd -P )"
}