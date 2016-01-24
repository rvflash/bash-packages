#!/usr/bin/env bash
set -o errexit -o pipefail -o errtrace
source ../testing.sh
source ../math.sh

# Default entries
declare -i -r TEST_NUMBER_TYPE_INT=127
readonly TEST_NUMBER_STR_INT="12"
readonly TEST_NUMBER_STR_BIG_INT="13"
readonly TEST_NUMBER_STR_FLOAT="12.45"
readonly TEST_NUMBER_STR_BIG_FLOAT="12.55"
readonly TEST_NUMBER_STR_BIGGER_FLOAT="13.45"
readonly TEST_NUMBER_STR_UNKNOWN="12s"

readonly TEST_IS_FLOAT="-11-11-11-01-11"

function test_isFloat ()
{
    local TEST

    # Check nothing
    TEST=$(isFloat)
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1

    # Check int type value
    TEST=$(isFloat ${TEST_NUMBER_TYPE_INT})
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1

    # Check int value in string
    TEST=$(isFloat ${TEST_NUMBER_STR_INT})
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1

    #  Check if it is a float value
    TEST=$(isFloat ${TEST_NUMBER_STR_FLOAT})
    echo -n "-$?"
    [[ "$TEST" -eq 1 ]] && echo -n 1

    # Check invalid number value
    TEST=$(isFloat ${TEST_NUMBER_STR_UNKNOWN})
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1
}


readonly TEST_IS_INT="-11-01-01-11-11"

function test_isInt ()
{
    local TEST

    # Check nothing
    TEST=$(isInt)
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1

    # Check int type value
    TEST=$(isInt ${TEST_NUMBER_TYPE_INT})
    echo -n "-$?"
    [[ "$TEST" -eq 1 ]] && echo -n 1

    # Check int value in string
    TEST=$(isInt ${TEST_NUMBER_STR_INT})
    echo -n "-$?"
    [[ "$TEST" -eq 1 ]] && echo -n 1

    #  Check if it is a float value
    TEST=$(isInt ${TEST_NUMBER_STR_FLOAT})
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1

    # Check invalid number value
    TEST=$(isInt ${TEST_NUMBER_STR_UNKNOWN})
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1
}


readonly TEST_IS_NUMERIC="-11-01-01-01-11"

function test_isNumeric ()
{
    local TEST

    # Check nothing
    TEST=$(isNumeric)
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1

    # Check int type value
    TEST=$(isNumeric ${TEST_NUMBER_TYPE_INT})
    echo -n "-$?"
    [[ "$TEST" -eq 1 ]] && echo -n 1

    # Check int value in string
    TEST=$(isNumeric ${TEST_NUMBER_STR_INT})
    echo -n "-$?"
    [[ "$TEST" -eq 1 ]] && echo -n 1

    #  Check if it is a float value
    TEST=$(isNumeric ${TEST_NUMBER_STR_FLOAT})
    echo -n "-$?"
    [[ "$TEST" -eq 1 ]] && echo -n 1

    # Check invalid number value
    TEST=$(isNumeric ${TEST_NUMBER_STR_UNKNOWN})
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1
}


readonly TEST_FLOAT_GREATER_THAN="-11-11-11-01-01-11-11-11-01"

function test_floatGreaterThan ()
{
    local TEST

    # Check nothing
    TEST=$(floatGreaterThan)
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1

    # Compare equal int values
    TEST=$(floatGreaterThan ${TEST_NUMBER_TYPE_INT} ${TEST_NUMBER_TYPE_INT})
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1

    # Compare equal float values
    TEST=$(floatGreaterThan ${TEST_NUMBER_STR_FLOAT} ${TEST_NUMBER_STR_FLOAT})
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1

    # Compare int value with float value
    TEST=$(floatGreaterThan ${TEST_NUMBER_STR_BIG_INT} ${TEST_NUMBER_STR_FLOAT})
    echo -n "-$?"
    [[ "$TEST" -eq 1 ]] && echo -n 1

    # Compare float value with int value
    TEST=$(floatGreaterThan ${TEST_NUMBER_STR_FLOAT} ${TEST_NUMBER_STR_INT})
    echo -n "-$?"
    [[ "$TEST" -eq 1 ]] && echo -n 1

    # Compare string value with int value
    TEST=$(floatGreaterThan ${TEST_NUMBER_STR_UNKNOWN} ${TEST_NUMBER_TYPE_INT})
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1

    # Compare float value with string value
    TEST=$(floatGreaterThan ${TEST_NUMBER_STR_FLOAT} ${TEST_NUMBER_STR_UNKNOWN})
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1

    # Compare float value with an another float value with same decimal
    TEST=$(floatGreaterThan ${TEST_NUMBER_STR_FLOAT} ${TEST_NUMBER_STR_BIG_FLOAT})
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1

    # Compare float value with a smaller float
    TEST=$(floatGreaterThan ${TEST_NUMBER_STR_BIGGER_FLOAT} ${TEST_NUMBER_STR_BIG_FLOAT})
    echo -n "-$?"
    [[ "$TEST" -eq 1 ]] && echo -n 1
}


readonly TEST_FLOAT_LOWER_THAN="-11-01-11"

function test_floatLowerThan ()
{
    local TEST

    # Check nothing
    TEST=$(floatLowerThan)
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1

    # Compare float value with an another float value with same decimal
    TEST=$(floatLowerThan ${TEST_NUMBER_STR_FLOAT} ${TEST_NUMBER_STR_BIG_FLOAT})
    echo -n "-$?"
    [[ "$TEST" -eq 1 ]] && echo -n 1

    # Compare float value with a smaller float
    TEST=$(floatLowerThan ${TEST_NUMBER_STR_BIGGER_FLOAT} ${TEST_NUMBER_STR_BIG_FLOAT})
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1

    # Other checks was validated by opposite function floatgreaterThan
}


readonly TEST_NUMERIC_TYPE="-11-01-01-01-11"

function test_numericType ()
{
    local TEST

    # Check nothing
    TEST=$(numericType)
    echo -n "-$?"
    [[ "$TEST" == "$BP_UNKNOWN_TYPE" ]] && echo -n 1

    # Check int type value
    TEST=$(numericType ${TEST_NUMBER_TYPE_INT})
    echo -n "-$?"
    [[ "$TEST" == "$BP_INT_TYPE" ]] && echo -n 1

    # Check int value in string
    TEST=$(numericType ${TEST_NUMBER_STR_INT})
    echo -n "-$?"
    [[ "$TEST" == "$BP_INT_TYPE" ]] && echo -n 1

    # Check float value in string
    TEST=$(numericType ${TEST_NUMBER_STR_FLOAT})
    echo -n "-$?"
    [[ "$TEST" == "$BP_FLOAT_TYPE" ]] && echo -n 1

    # Check invalid number value
    TEST=$(numericType ${TEST_NUMBER_STR_UNKNOWN})
    echo -n "-$?"
    [[ "$TEST" == "$BP_UNKNOWN_TYPE" ]] && echo -n 1
}


# Launch all functional tests
bashUnit "isFloat" "${TEST_IS_FLOAT}" "$(test_isFloat)"
bashUnit "isInt" "${TEST_IS_INT}" "$(test_isInt)"
bashUnit "isNumeric" "${TEST_IS_NUMERIC}" "$(test_isNumeric)"
bashUnit "floatGreaterThan" "${TEST_FLOAT_GREATER_THAN}" "$(test_floatGreaterThan)"
bashUnit "floatLowerThan" "${TEST_FLOAT_LOWER_THAN}" "$(test_floatLowerThan)"
bashUnit "numericType" "${TEST_NUMERIC_TYPE}" "$(test_numericType)"