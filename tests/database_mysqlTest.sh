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


readonly TEST_DATABASE_MYSQL_MYSQL_CONNECT="-11-11-01"

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

    # Check with all required parameters
    TEST=$(mysqlConnect "${TEST_DATABASE_MYSQL_HOST}" "${TEST_DATABASE_MYSQL_USER}" "${TEST_DATABASE_MYSQL_PASS}" "${TEST_DATABASE_MYSQL_DB}")
    echo -n "-$?"
    [[ "$TEST" -gt 0 ]] && echo -n 1
}


readonly TEST_DATABASE_MYSQL_AFFECTED_ROWS="-11"

function test_mysqlAffectedRows ()
{
    echo "mysqlAffectedRows"
}


readonly TEST_DATABASE_MYSQL_MYSQL_CLOSE="-11"

function test_mysqlClose ()
{
    echo "mysqlClose"
}


readonly TEST_DATABASE_MYSQL_MYSQL_ESCAPE_STRING="-11-11-011"

function test_mysqlEscapeString ()
{
    local TEST

    # Check nothing
    TEST=$(mysqlEscapeString)
    echo -n "-$?"
    [[ -z "${TEST}" ]] && echo -n 1

    # Check with single quote
    TEST=$(mysqlEscapeString "value'DELETE FROM")
    echo -n "-$?"
    [[ "${TEST}" == "value\'DELETE FROM" ]] && echo -n 1

    # Check with single quote
    TEST=$(mysqlEscapeString 'value="h
    erve"')
    echo -n "-$?"
    echo "${TEST}"
    [[ -z "${TEST}" ]] && echo -n 1
}


readonly TEST_DATABASE_MYSQL_MYSQL_LAST_ERROR="-01"

function test_mysqlLastError ()
{
    local TEST

    # Check nothing
    TEST=$(mysqlLastError)
    echo -n "-$?"
    [[ -z "${TEST}" ]] && echo -n 1
}


readonly TEST_DATABASE_MYSQL_MYSQL_FETCH_ALL="-01"

function test_mysqlFetchAll ()
{
    echo "mysqlFetchAll"
}


readonly TEST_DATABASE_MYSQL_MYSQL_FETCH_ASSOC="-01"

function test_mysqlFetchAssoc ()
{
    echo "mysqlFetchAssoc"
}


readonly TEST_DATABASE_MYSQL_MYSQL_FETCH_ARRAY="-01"

function test_mysqlFetchArray ()
{
    echo "mysqlFetchArray"
}


readonly TEST_DATABASE_MYSQL_MYSQL_NUM_ROWS="-01"

function test_mysqlNumRows ()
{
    echo "mysqlNumRows"
}


readonly TEST_DATABASE_MYSQL_MYSQL_OPTION="-01"

function test_mysqlOption ()
{
    echo "mysqlOption"
}


readonly TEST_DATABASE_MYSQL_MYSQL_QUERY="-11-11-01"

function test_mysqlQuery ()
{
    local TEST DB_TEST

    DB_TEST=$(mysqlConnect "${TEST_DATABASE_MYSQL_HOST}" "${TEST_DATABASE_MYSQL_USER}" "${TEST_DATABASE_MYSQL_PASS}" "${TEST_DATABASE_MYSQL_DB}")

    # Check nothing
    TEST=$(mysqlQuery)
    echo -n "-$?"
    echo "E${DB_TEST}E"
    echo "R${TEST}R"
    [[ -z "${TEST}" ]] && echo -n 1

    # Check select data on unexisting table
    TEST=$(mysqlQuery "${DB_TEST}" "${TEST_DATABASE_MYSQL_BAD_SELECT}")
    echo -n "-$?"
    echo "E${DB_TEST}E"
    echo "R${TEST}R"
    [[ -z "${TEST}" ]] && echo -n 1

    # Check select one row
    TEST=$(mysqlQuery "${DB_TEST}" "${TEST_DATABASE_MYSQL_SELECT_ONE_ROW}")
    echo -n "-$?"
    echo "E${DB_TEST}E"
    echo "R${TEST}R"
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