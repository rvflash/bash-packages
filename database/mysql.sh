#!/usr/bin/env bash

# Require mysql command line tool
declare -r -i BP_MYSQL="$(if [[ -z "$(type -p mysql)" ]]; then echo 0; else echo 1; fi)"
declare -r BP_MYSQL_QUERY_OPTIONS="--unbuffered --quick --show-warnings --skip-column-names"

declare -A BP_MYSQL_CONNECT
declare BP_MYSQL_ERROR

# Mysql message
declare -r BP_MYSQL_MSG_NO_MYSQL="Mysql as command line tool has required"
declare -r BP_MYSQL_MSG_NO_QUERY="Missing query"
declare -r BP_MYSQL_MSG_NO_CONNECT="Please specify a hostname, user and password to connect and a database name"

##
# Registry to save connection informations to a mysql server
# @param string Host
# @param string Username
# @param string password
# @param string Database
function mysql ()
{
    if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" ]]; then
        BP_MYSQL_ERROR="${BP_MYSQL_MSG_NO_CONNECT}"
        return 1
    fi

    BP_MYSQL_CONNECT["HOST"]="$1"
    BP_MYSQL_CONNECT["USER"]="$2"
    BP_MYSQL_CONNECT["PASS"]="$3"
    BP_MYSQL_CONNECT["DB"]="$4"
}

##
# Returns a string description of the last error
# @return string
function mysqlLastError ()
{
    echo -n "${BP_MYSQL_ERROR}"
}

##
# Performs a query on the database
# @param string Query
# @param string Host
# @param string Username
# @param string password
# @param string Database
# @return int 1 on success or 0 on failure
function mysqlQuery ()
{
    if [[ ${BP_MYSQL} -eq 0 ]]; then
        BP_MYSQL_ERROR="${BP_MYSQL_MSG_NO_MYSQL}"
        return 2
    fi
    local QUERY="$1"
    if [[ -z "$QUERY" ]]; then
        BP_MYSQL_ERROR="${BP_MYSQL_MSG_NO_QUERY}"
        return 1
    fi
    local MYSQL_HOST="$2"
    local MYSQL_USER="$3"
    local MYSQL_PASS="$4"
    local MYSQL_DB="$5"

    if [[ -z "$MYSQL_HOST" || -z "$MYSQL_USER" || -z "$MYSQL_PASS" || -z "$MYSQL_DB" ]]; then
        if [[ -z "${BP_MYSQL_CONNECT[HOST]}" ]]; then
            BP_MYSQL_ERROR="${BP_MYSQL_MSG_NO_CONNECT}"
            return 1
        fi
        MYSQL_HOST="${BP_MYSQL_CONNECT[HOST]}"
        MYSQL_USER="${BP_MYSQL_CONNECT[USER]}"
        MYSQL_PASS="${BP_MYSQL_CONNECT[PASS]}"
        MYSQL_DB="${BP_MYSQL_CONNECT[DB]}"
    fi

    local MSG
    declare -i RES
    MSG=$(mysql ${BP_MYSQL_QUERY_OPTIONS} -B -h "${MYSQL_HOST}" -u "${MYSQL_USER}" -p"${MYSQL_PASS}" ${MYSQL_DB} -e "${QUERY}" 2>&1)
    RES=$?

    if [[ ${RES} -eq 0 ]]; then
        echo -n 1
        BP_MYSQL_ERROR=""
    else
        # An error occured
        echo -n 0
        BP_MYSQL_ERROR="${MSG}"
    fi

    return ${RES}
}

##
# Escapes special characters in a string for use in an SQL statement
# Characters encoded are NUL (ASCII 0), \n, \r, \, ', "
function mysqlQuote ()
{
    echo "cotcot"
}