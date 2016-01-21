#!/usr/bin/env bash

##
# Convert a Yaml file into readable string for array convertion
# @example '([K1]="V1" [K2]="V2")'
# @param string $1 Yaml file path to parse
# @return stringableArray YAML_TO_ARRAY
function yamlFileToArray ()
{
    if [[ -n "$1" ]] && [[ -f "$1" ]]; then
        # Remove comment lines, empty lines and format line to build associative array for bash (protect CSV output)
        local YAML_TO_ARRAY
        YAML_TO_ARRAY=$(sed -e "/^#/d" \
                            -e "/^$/d" \
                            -e "s/\"/'/g" \
                            -e "s/,/;/g" \
                            -e "s/=//g" \
                            -e "s/\ :[^:\/\/]/=\"/g" \
                            -e "s/$/\"/g" \
                            -e "s/ *=/]=/g" \
                            -e "s/^/[/g" "$1")
        if [[ $? -eq 0 ]]; then
            echo -n "(${YAML_TO_ARRAY})"
            return
        fi
    fi

    return 1
}