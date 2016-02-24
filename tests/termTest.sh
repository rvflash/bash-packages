#!/usr/bin/env bash
set -o errexit -o pipefail -o errtrace
source ../testing.sh
source ../term.sh

declare -r TEST_TERM_PROGRESS_BAR_NAME="Upload"
declare -r TEST_TERM_PROGRESS_BAR_0="$(echo -e "\rUpload [--------------------] 0% ")"
declare -r TEST_TERM_PROGRESS_BAR_50="$(echo -e "\rUpload [++++++++++----------] 50% ")"
declare -r TEST_TERM_PROGRESS_BAR_100="$(echo -e "\rUpload [++++++++++++++++++++] 100% ")"


readonly TEST_TERM_CONFIRM="-1"

function test_confirm ()
{
    echo "-1"
}


readonly TEST_TERM_DIALOG="-1"

function test_dialog ()
{
    echo "-1"
}


readonly TEST_TERM_PROGRESS_BAR="-11-11-01-01-01-11"

function test_progressBar ()
{
    local TEST

    # Check nothing
    TEST=$(progressBar)
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1

    # Check with only a job name
    TEST=$(progressBar "${TEST_TERM_PROGRESS_BAR_NAME}")
    echo -n "-$?"
    [[ "$TEST" == "${BP_TERM_ERROR}" ]] && echo -n 1

    # Check with starting job
    TEST=$(progressBar "${TEST_TERM_PROGRESS_BAR_NAME}" 0 100)
    echo -n "-$?"
    [[ "$TEST" == "${TEST_TERM_PROGRESS_BAR_0}" ]] && echo -n 1

    # Check with job at 50%
    TEST=$(progressBar "${TEST_TERM_PROGRESS_BAR_NAME}" 50 100)
    echo -n "-$?"
    [[ "$TEST" == "${TEST_TERM_PROGRESS_BAR_50}" ]] && echo -n 1

    # Check with ending job
    TEST=$(progressBar "${TEST_TERM_PROGRESS_BAR_NAME}" 100 100)
    echo -n "-$?"
    [[ "$TEST" == "${TEST_TERM_PROGRESS_BAR_100}" ]] && echo -n 1

    # Check with negative max data (error)
    TEST=$(progressBar "${TEST_TERM_PROGRESS_BAR_NAME}" 70 -1)
    echo -n "-$?"
    [[ "$TEST" == "${BP_TERM_ERROR}" ]] && echo -n 1
}


readonly TEST_TERM_WINDOW_SIZE="-011-01-01-011"

function test_windowSize ()
{
   local TEST

    # Check
    TEST=$(windowSize)
    echo -n "-$?"
    [[ -n "$TEST" ]] && echo -n 1
    declare -a SIZE="${TEST}"
    [[ "${#SIZE[@]}" -eq 2 && "${SIZE[0]}" -gt 0  && "${SIZE[1]}" -gt 0 ]] && echo -n 1

    # Check only width
    TEST=$(windowSize "width")
    echo -n "-$?"
    [[ "$TEST" -gt 0 ]] && echo -n 1

    # Check only height
    TEST=$(windowSize "height")
    echo -n "-$?"
    [[ "$TEST" -gt 0 ]] && echo -n 1

    # Check only anything
    TEST=$(windowSize "any")
    echo -n "-$?"
    [[ -n "$TEST" ]] && echo -n 1
    declare -a SIZE="${TEST}"
    [[ "${#SIZE[@]}" -eq 2 && "${SIZE[0]}" -gt 0  && "${SIZE[1]}" -gt 0 ]] && echo -n 1
}


# Launch all functional tests
bashUnit "confirm" "${TEST_TERM_CONFIRM}" "$(test_confirm)"
bashUnit "dialog" "${TEST_TERM_DIALOG}" "$(test_dialog)"
bashUnit "progressBar" "${TEST_TERM_PROGRESS_BAR}" "$(test_progressBar)"
bashUnit "windowSize" "${TEST_TERM_WINDOW_SIZE}" "$(test_windowSize)"