#!/usr/bin/env bash

declare -r -i BP_BASE64="$(if [[ -z "$(type -p base64)" ]]; then echo 0; else echo 1; fi)"
declare -r BP_NET_WRK_DIR="/tmp"


##
# Decodes data encoded with MIME base64
function base64Decode ()
{
    # base64 command line tool is required
    if [[ ${BP_BASE64} -eq 0 ]]; then
        return 2
    elif [[ -z "$1" ]]; then
        return 1
    fi
}

##
# Encodes data with MIME base64
function base64Encode ()
{
    # base64 command line tool is required
    if [[ ${BP_BASE64} -eq 0 ]]; then
        return 2
    elif [[ -z "$1" ]]; then
        return 1
    fi
}