#!/usr/bin/env bash
set -o errexit -o pipefail -o errtrace
source ../testing.sh
source ../database/mysql.sh

# Default entries
declare -r TEST_DATABASE_MYSQL_HOST="localhost"
declare -r TEST_DATABASE_MYSQL_USER="mysql"
declare -r TEST_DATABASE_MYSQL_PASS=""
declare -r TEST_DATABASE_MYSQL_DB="test"
declare -r TEST_DATABASE_MYSQL_SELECT_ONE_ROW="SELECT * FROM rv LIMIT 1;"
declare -r TEST_DATABASE_MYSQL_SELECT_ROWS="SELECT * FROM rv;"
declare -r TEST_DATABASE_MYSQL_BAD_SELECT="SELECT * FROM vv;"
declare -r TEST_DATABASE_MYSQL_INSERT="INSERT INTO rv (id, name) VALUES (3, FLOOR(RAND()*1000)) ON DUPLICATE KEY UPDATE name=VALUES(name);"
declare -r TEST_DATABASE_MYSQL_STR_SQUOTED="value'DELETE FROM"
declare -r TEST_DATABASE_MYSQL_STR_PSQUOTED="value\'DELETE FROM"
declare -r TEST_DATABASE_MYSQL_STR_DQUOTED='value="DELETE FROM'
declare -r TEST_DATABASE_MYSQL_STR_PDQUOTED='value=\"DELETE FROM'
declare -r TEST_DATABASE_MYSQL_STR_NEWLINE='valu\e="h
e rve"'
declare -r TEST_DATABASE_MYSQL_STR_PNEWLINE='valu\\e=\"h\ne rve\"'

readonly TEST_DATABASE_MYSQL_MYSQL_CONNECT="-11-11-01-11"

function test_mysqlConnect ()
{
    local TEST

    # Check nothing
    TEST=$(mysqlConnect)
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1

    # Check without all required parameters
    TEST=$(mysqlConnect "${TEST_DATABASE_MYSQL_HOST}" "${TEST_DATABASE_MYSQL_USER}" "${TEST_DATABASE_MYSQL_PASS}")
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1

    # Check with valid parameters
    TEST=$(mysqlConnect "${TEST_DATABASE_MYSQL_HOST}" "${TEST_DATABASE_MYSQL_USER}" "${TEST_DATABASE_MYSQL_PASS}" "${TEST_DATABASE_MYSQL_DB}")
    echo -n "-$?"
    [[ "$TEST" -gt 0 ]] && echo -n 1

    # Check with invalid parameters
    TEST=$(mysqlConnect "${TEST_DATABASE_MYSQL_HOST}" "${TEST_DATABASE_MYSQL_USER}" "bad" "${TEST_DATABASE_MYSQL_DB}")
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1
}


readonly TEST_DATABASE_MYSQL_AFFECTED_ROWS="-01-01-01-001"

function test_mysqlAffectedRows ()
{
    local TEST DB_TEST QUERY_TEST

    DB_TEST=$(mysqlConnect "${TEST_DATABASE_MYSQL_HOST}" "${TEST_DATABASE_MYSQL_USER}" "${TEST_DATABASE_MYSQL_PASS}" "${TEST_DATABASE_MYSQL_DB}")

    # Check with no link to database
    TEST=$(mysqlAffectedRows)
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1

    # Check with fake link to database
    TEST=$(mysqlAffectedRows "123")
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1

    # Check with valid link to database without affected rows
    TEST=$(mysqlAffectedRows "${DB_TEST}")
    echo -n "-$?"
    [[ "$TEST" -eq 0 ]] && echo -n 1

    # Check with valid link to database without affected rows
    QUERY_TEST=$(mysqlQuery "${DB_TEST}" "${TEST_DATABASE_MYSQL_INSERT}")
    echo -n "-$?"
    TEST=$(mysqlAffectedRows "${DB_TEST}")
    echo -n "$?"
    [[ "$TEST" -eq 1 ]] && echo -n 1
}


readonly TEST_DATABASE_MYSQL_MYSQL_CLOSE="-11-11-1011"

function test_mysqlClose ()
{
    local TEST DB_TEST DB_TEST_FILE

    DB_TEST=$(mysqlConnect "${TEST_DATABASE_MYSQL_HOST}" "${TEST_DATABASE_MYSQL_USER}" "${TEST_DATABASE_MYSQL_PASS}" "${TEST_DATABASE_MYSQL_DB}")
    DB_TEST_FILE="${BP_MYSQL_WRK_DIR}/${DB_TEST}${BP_MYSQL_CONNECT_EXT}"

    # Check nothing
    TEST=$(mysqlClose)
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1

    # Check With invalid link
    TEST=$(mysqlClose "123")
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1

    # Check With valid link
    [[ -f "${DB_TEST_FILE}" ]] && echo -n "-1"
    TEST=$(mysqlClose "${DB_TEST}")
    echo -n "$?"
    [[ -z "$TEST" ]] && echo -n 1
    [[ ! -f "${DB_TEST_FILE}" ]] && echo -n "1"
}


readonly TEST_DATABASE_MYSQL_MYSQL_ESCAPE_STRING="-01-01-01-01"

function test_mysqlEscapeString ()
{
    local TEST

    # Check nothing
    TEST=$(mysqlEscapeString)
    echo -n "-$?"
    [[ -z "${TEST}" ]] && echo -n 1

    # Check with single quote
    TEST=$(mysqlEscapeString "${TEST_DATABASE_MYSQL_STR_SQUOTED}")
    echo -n "-$?"
    [[ "${TEST}" == "${TEST_DATABASE_MYSQL_STR_PSQUOTED}" ]] && echo -n 1

    # Check with double quote
    TEST=$(mysqlEscapeString "${TEST_DATABASE_MYSQL_STR_DQUOTED}")
    echo -n "-$?"
    [[ "${TEST}" == "${TEST_DATABASE_MYSQL_STR_PDQUOTED}" ]] && echo -n 1

    # Check with double quote, backslash and newline
    TEST=$(mysqlEscapeString "${TEST_DATABASE_MYSQL_STR_NEWLINE}")
    echo -n "-$?"
    [[ "${TEST}" == "${TEST_DATABASE_MYSQL_STR_PNEWLINE}" ]] && echo -n 1
}


readonly TEST_DATABASE_MYSQL_MYSQL_LAST_ERROR="-01-01-01-01"

function test_mysqlLastError ()
{
    local TEST DB_TEST QUERY_TEST

    DB_TEST=$(mysqlConnect "${TEST_DATABASE_MYSQL_HOST}" "${TEST_DATABASE_MYSQL_USER}" "${TEST_DATABASE_MYSQL_PASS}" "${TEST_DATABASE_MYSQL_DB}")

    # Check with no link to database
    TEST=$(mysqlLastError)
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1

    # Check with fake link to database
    TEST=$(mysqlLastError "123")
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1

    # Check with valid link to database without error
    TEST=$(mysqlLastError "${DB_TEST}")
    echo -n "-$?"
    [[ -z "$TEST" ]] && echo -n 1

    # Check with valid link to database without error
    QUERY_TEST=$(mysqlQuery "${DB_TEST}" "${TEST_DATABASE_MYSQL_BAD_SELECT}")
    TEST=$(mysqlLastError "${DB_TEST}")
    echo -n "-$?"
    [[ -n "$TEST" ]] && echo -n 1
}


readonly TEST_DATABASE_MYSQL_MYSQL_FETCH_ALL="-01"

function test_mysqlFetchAll ()
{
    echo -n "-01"
}


readonly TEST_DATABASE_MYSQL_MYSQL_FETCH_ASSOC="-01"

function test_mysqlFetchAssoc ()
{
    echo -n "-01"
}


readonly TEST_DATABASE_MYSQL_MYSQL_FETCH_ARRAY="-01"

function test_mysqlFetchArray ()
{
    echo -n "-01"
}


readonly TEST_DATABASE_MYSQL_MYSQL_NUM_ROWS="-01"

function test_mysqlNumRows ()
{
    echo -n "-01"
}


readonly TEST_DATABASE_MYSQL_MYSQL_OPTION="-01"

function test_mysqlOption ()
{
    echo -n "-01"
}


readonly TEST_DATABASE_MYSQL_MYSQL_QUERY="-11-11-11-01"

function test_mysqlQuery ()
{
    local TEST DB_TEST

    DB_TEST=$(mysqlConnect "${TEST_DATABASE_MYSQL_HOST}" "${TEST_DATABASE_MYSQL_USER}" "${TEST_DATABASE_MYSQL_PASS}" "${TEST_DATABASE_MYSQL_DB}")

    # Check nothing
    TEST=$(mysqlQuery)
    echo -n "-$?"
    [[ -z "${TEST}" ]] && echo -n 1

    # Check With invalid database link
    TEST=$(mysqlQuery "123" "${TEST_DATABASE_MYSQL_SELECT_ONE_ROW}")
    echo -n "-$?"
    [[ -z "${TEST}" ]] && echo -n 1

    # Check select data on unexisting table
    TEST=$(mysqlQuery "${DB_TEST}" "${TEST_DATABASE_MYSQL_BAD_SELECT}")
    echo -n "-$?"
    [[ -z "${TEST}" ]] && echo -n 1

    # Check select one row on valid database
    TEST=$(mysqlQuery "${DB_TEST}" "${TEST_DATABASE_MYSQL_SELECT_ONE_ROW}")
    echo -n "-$?"
    [[ -z "${TEST}" ]] && echo -n 1
}


# Launch all functional tests
bashUnit "mysqlConnect" "${TEST_DATABASE_MYSQL_MYSQL_CONNECT}" "$(test_mysqlConnect)"
bashUnit "mysqlAffectedRows" "${TEST_DATABASE_MYSQL_AFFECTED_ROWS}" "$(test_mysqlAffectedRows)"
bashUnit "mysqlClose" "${TEST_DATABASE_MYSQL_MYSQL_CLOSE}" "$(test_mysqlClose)"
bashUnit "mysqlEscapeString" "${TEST_DATABASE_MYSQL_MYSQL_ESCAPE_STRING}" "$(test_mysqlEscapeString)"
bashUnit "mysqlLastError" "${TEST_DATABASE_MYSQL_MYSQL_LAST_ERROR}" "$(test_mysqlLastError)"
bashUnit "mysqlFetchAll" "${TEST_DATABASE_MYSQL_MYSQL_FETCH_ALL}" "$(test_mysqlFetchAll)"
bashUnit "mysqlFetchAssoc" "${TEST_DATABASE_MYSQL_MYSQL_FETCH_ASSOC}" "$(test_mysqlFetchAssoc)"
bashUnit "mysqlFetchArray" "${TEST_DATABASE_MYSQL_MYSQL_FETCH_ARRAY}" "$(test_mysqlFetchArray)"
bashUnit "mysqlNumRows" "${TEST_DATABASE_MYSQL_MYSQL_NUM_ROWS}" "$(test_mysqlNumRows)"
bashUnit "mysqlOption" "${TEST_DATABASE_MYSQL_MYSQL_OPTION}" "$(test_mysqlOption)"
bashUnit "mysqlQuery" "${TEST_DATABASE_MYSQL_MYSQL_QUERY}" "$(test_mysqlQuery)"