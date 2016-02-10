#!/usr/bin/env bash
set -o errexit -o pipefail -o errtrace
source ../testing.sh
source ../encoding/base64.sh

# Default entries
declare -r TEST_ENCODING_STR=""
declare -r TEST_ENCODING_ENCODED_STR=""


readonly TEST_ENCODING_BASE64_DECODE="-11"

function test_base64Decode ()
{
    echo -n "-11"
}


readonly TEST_ENCODING_BASE64_ENCODE="-11"

function test_base64Encode ()
{
    echo -n "-11"
}


# Launch all functional tests
bashUnit "base64Decode" "${TEST_ENCODING_BASE64_DECODE}" "$(test_base64Decode)"
bashUnit "base64Encode" "${TEST_ENCODING_BASE64_ENCODE}" "$(test_base64Encode)"
