#!/usr/bin/env bash

##
# Decodes a YAML string
# @example
#     K1    : Value 1
#     K2    : V2
#
#     > '([K1]="Value 1" [K2]="V2")'
#
# @param string $1 Yaml string to parse
# @return arrayToString
function yamlDecode ()
{
    local YAML="$1"
    if [[ -z "$YAML" || "$YAML" != *" : "* ]]; then
        echo -n "()"
        return 1
    fi

    # Remove comment lines, empty lines and format line to build associative array for bash
    YAML=$(echo "${YAML}" | sed -e "/^#/d" -e "/^$/d" -e "s/\"/'/g" -e "s/=//g" -e "s/\ :[^:\/\/]/=\"/g" -e "s/$/\"/g" -e "s/ *=/]=/g" -e "s/^/[/g")
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    echo -n "(${YAML})"
}

##
# Encodes a bash associative array as YAML string
# @example '([K1]="Value 1" [K2]="V2")'
# @param arrayToString $1 Associative array
# @return string
function yamlEncode ()
{
    local YAML="$1"
    if [[ -z "${YAML}" || "()" == "${YAML}" ]]; then
        return 1
    fi
    declare -A YAML="${YAML}"

    # Get left column padding
    local KEY
    declare -i PAD=0
    for KEY in "${!YAML[@]}"; do
        if [[ ${PAD} -lt "${#KEY}" ]]; then
            PAD="${#KEY}"
        fi
    done

    # Print associative array as YAML string
    for KEY in "${!YAML[@]}"; do
        echo $(printf "%-${PAD}s" "$KEY"; echo -n " : ${YAML[$KEY]}")
    done
}

##
# Convert a Yaml file into readable string for array convertion
# @example '([K1]="V1" [K2]="V2")'
# @param string $1 Yaml file path to parse
# @return arrayToString
function yamlFileDecode ()
{
    local FILE_PATH="$1"
    if [[ -n "${FILE_PATH}" && -f "${FILE_PATH}" ]]; then
        local YAML
        YAML=$(yamlDecode "$(cat "${FILE_PATH}")")
        if [[ $? -eq 0 ]]; then
            echo -n "${YAML}"
            return
        fi
    fi

    return 1
}

##
# Encodes a bash associative array and save it as Yaml file
# @param arrayToString $1 Associative array
# @param string $2 Yaml file path to create
# @return arrayToString
function yamlFileEncode ()
{
    local YAML="$1"
    local FILE_PATH="$2"

    if [[ -n "${FILE_PATH}" && ! -d "${FILE_PATH}" ]]; then
        YAML=$(yamlEncode "${YAML}")
        if [[ $? -eq 0 && -n "${YAML}" ]]; then
            echo "${YAML}" > "${FILE_PATH}"
            if [[ $? -eq 0 ]]; then
                return
            fi
        fi
    fi

    return 1
}