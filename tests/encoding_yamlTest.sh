#!/usr/bin/env bash
set -o errexit -o pipefail -o errtrace
source ../testing.sh
source ../encoding/yaml.sh

# ONE         : First value
# TWO         : Second
# THREE       : Third element
# FOUR        : Fourth

# Default entries
declare -r TEST_ENCODING_YAML_FILE_PATH="${PWD}/unit/yaml01.yaml"
declare -r TEST_ENCODING_YAML_BAD_FILE_PATH="${PWD}/unit/yaml02.yaml"
declare -r TEST_ENCODING_YAML_TMP_FILE_PATH="/tmp/bp.yaml"
declare -r TEST_ENCODING_YAML_STRING="$(cat "${TEST_ENCODING_YAML_FILE_PATH}")"
declare -r TEST_ENCODING_YAML_ARRAY="([ONE]=\"First value\" [TWO]=\"Second\" [THREE]=\"Third element\" [FOUR]=\"Fourth\")"


readonly TEST_ENCODING_YAML_YAML_DECODE="-11-11-011"

function test_yamlDecode ()
{
    local TEST

    # Check nothing
    TEST=$(yamlDecode)
    echo -n "-$?"
    [[ "${TEST}" == "()" ]] && echo -n 1

    # Check invalid yaml (without at less " : ")
    TEST=$(yamlDecode "empty")
    echo -n "-$?"
    [[ "${TEST}" == "()" ]] && echo -n 1

    # Check yaml
    TEST=$(yamlDecode "$TEST_ENCODING_YAML_STRING")
    echo -n "-$?"
    [[ -n "${TEST}" ]] && echo -n 1
    declare -A YAML="${TEST}"
    [[ "First value" == "${YAML[ONE]}" && "Second" == "${YAML[TWO]}" && "Third element" == "${YAML[THREE]}" && "Fourth" == "${YAML[FOUR]}" ]] && echo -n 1
}


readonly TEST_ENCODING_YAML_YAML_ENCODE="-11-11-01-01"

function test_yamlEncode ()
{
    local TEST
    declare -A TEST_ARRAY="${TEST_ENCODING_YAML_ARRAY}"

    # Check nothing
    TEST=$(yamlEncode)
    echo -n "-$?"
    [[ -z "${TEST}" ]] && echo -n 1

    # Check empty array
    TEST=$(yamlEncode "()")
    echo -n "-$?"
    [[ -z "${TEST}" ]] && echo -n 1

    # Check invalid yaml array
    TEST=$(yamlEncode "empty")
    echo -n "-$?"
    [[ "${TEST}" == "0 : empty" ]] && echo -n 1

    # Check yaml
    TEST=$(yamlEncode "${TEST_ENCODING_YAML_ARRAY}")
    echo -n "-$?"
    [[ -n "${TEST}" && $(wc -l <<< "${TEST}") -eq "${#TEST_ARRAY[@]}" ]] && echo -n 1
}


readonly TEST_ENCODING_YAML_YAML_FILE_DECODE="-11-11-011"

function test_yamlFileDecode ()
{
    local TEST

    # Check nothing
    TEST=$(yamlFileDecode)
    echo -n "-$?"
    [[ -z "${TEST}" ]] && echo -n 1

    # Check unexitant file path
    TEST=$(yamlFileDecode "${TEST_ENCODING_YAML_BAD_FILE_PATH}")
    echo -n "-$?"
    [[ -z "${TEST}" ]] && echo -n 1

    # Check valid yaml file path
    TEST=$(yamlFileDecode "${TEST_ENCODING_YAML_FILE_PATH}")
    echo -n "-$?"
    [[ -n "${TEST}" ]] && echo -n 1
    declare -A YAML="${TEST}"
    [[ "First value" == "${YAML[ONE]}" && "Second" == "${YAML[TWO]}" && "Third element" == "${YAML[THREE]}" && "Fourth" == "${YAML[FOUR]}" ]] && echo -n 1
}


readonly TEST_ENCODING_YAML_YAML_FILE_ENCODE="-11-11-11-11-11-01"

function test_yamlFileEncode ()
{
    local TEST
    declare -A TEST_ARRAY="${TEST_ENCODING_YAML_ARRAY}"

    # Check nothing
    TEST=$(yamlFileEncode)
    echo -n "-$?"
    [[ -z "${TEST}" ]] && echo -n 1

    # Check with just arrayToString
    TEST=$(yamlFileEncode "${TEST_ENCODING_YAML_ARRAY}")
    echo -n "-$?"
    [[ -z "${TEST}" ]] && echo -n 1

    # Check with valid arrayToString and invalid path
    TEST=$(yamlFileEncode "${TEST_ENCODING_YAML_ARRAY}" "${PWD}")
    echo -n "-$?"
    [[ -z "${TEST}" ]] && echo -n 1

    # Check with empty value and valid path
    TEST=$(yamlFileEncode "" "${TEST_ENCODING_YAML_TMP_FILE_PATH}")
    echo -n "-$?"
    [[ -z "${TEST}" ]] && echo -n 1

    # Check with empty array and valid path
    TEST=$(yamlFileEncode "()" "${TEST_ENCODING_YAML_TMP_FILE_PATH}")
    echo -n "-$?"
    [[ -z "${TEST}" ]] && echo -n 1

    # Check with valid arrayToString and valid path
    if [[ -f "${TEST_ENCODING_YAML_TMP_FILE_PATH}" ]]; then
        rm -f "${TEST_ENCODING_YAML_TMP_FILE_PATH}"
    fi
    TEST=$(yamlFileEncode "${TEST_ENCODING_YAML_ARRAY}" "${TEST_ENCODING_YAML_TMP_FILE_PATH}")
    echo -n "-$?"
    [[ -z "${TEST}" && $(wc -l < "${TEST_ENCODING_YAML_TMP_FILE_PATH}") -eq "${#TEST_ARRAY[@]}" ]] && echo -n 1

    # Clean workspace
    if [[ -f "${TEST_ENCODING_YAML_TMP_FILE_PATH}" ]]; then
        rm -f "${TEST_ENCODING_YAML_TMP_FILE_PATH}"
    fi
}


# Launch all functional tests
bashUnit "yamlDecode" "${TEST_ENCODING_YAML_YAML_DECODE}" "$(test_yamlDecode)"
bashUnit "yamlEncode" "${TEST_ENCODING_YAML_YAML_ENCODE}" "$(test_yamlEncode)"
bashUnit "yamlFileDecode" "${TEST_ENCODING_YAML_YAML_FILE_DECODE}" "$(test_yamlFileDecode)"
bashUnit "yamlFileEncode" "${TEST_ENCODING_YAML_YAML_FILE_ENCODE}" "$(test_yamlFileEncode)"
