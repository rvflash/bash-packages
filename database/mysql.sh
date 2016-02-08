#!/usr/bin/env bash

# Require mysql command line tool
declare -r -i BP_MYSQL="$(if [[ -z "$(type -p mysql)" ]]; then echo 0; else echo 1; fi)"
declare -r -i BP_MYSQL_WRK=${RANDOM}
declare -r BP_MYSQL_COLUMN_NAMES_OPTS="--skip-column-names"
declare -r BP_MYSQL_OPTS="--batch --unbuffered --quick --show-warnings"
declare -r BP_MYSQL_BASIC_OPTS="${BP_MYSQL_OPTS} ${BP_MYSQL_COLUMN_NAMES_OPTS}"
declare -r BP_MYSQL_WRK_DIR="/tmp/bp_mysql"
declare -r BP_MYSQL_CONNECT_EXT=".cnx"
declare -r BP_MYSQL_RESULT_EXT=".res"
declare -r BP_MYSQL_COLUMN_NAMES_EXT=".nms"
declare -r BP_MYSQL_AFFECTED_ROW_EXT=".afr"
declare -r BP_MYSQL_ERROR_EXT=".err"
declare -r BP_MYSQL_CHK_SEP="::"
declare -r BP_MYSQL_SELECT="[Ss][Ee][Ll][Ee][Cc][Tt]"
declare -r BP_MYSQL_SHOW="[Ss][Hh][Oo][Ww]"
declare -r BP_MYSQL_DESC="[Dd][Ee][Ss][Cc]"
declare -r BP_MYSQL_EXPLAIN="[Ee][Xx][Pp][Ll][Aa][Ii][Nn]"
declare -r BP_MYSQL_INSERT="[Ii][Nn][Ss][Ee][Rr][Tt]"
declare -r BP_MYSQL_UPDATE="[Uu][Pp][Dd][Aa][Tt][Ee]"
declare -r BP_MYSQL_REPLACE="[Rr][Ee][Pp][Ll][Aa][Cc][Ee]"
declare -r BP_MYSQL_DELETE="[Dd][Ee][Ll][Ee][Tt][Ee]"
declare -r BP_MYSQL_AFFECTED_ROW_COUNT=";SELECT ROW_COUNT();"

# Constants
declare -r -i BP_MYSQL_HOST=1
declare -r -i BP_MYSQL_USER=2
declare -r -i BP_MYSQL_PASS=3
declare -r -i BP_MYSQL_DB=4
declare -r -i BP_MYSQL_TO=5
declare -r -i BP_MYSQL_CACHED=6
declare -r -i BP_MYSQL_RESULT_RAW=100
declare -r -i BP_MYSQL_RESULT_NUM=101
declare -r -i BP_MYSQL_RESULT_ASSOC=102
declare -r -i BP_MYSQL_UNKNOWN_METHOD=200
declare -r -i BP_MYSQL_SELECTING_METHOD=201
declare -r -i BP_MYSQL_AFFECTING_METHOD=202

##
# @returnStatus 1 If query method is not INSERT, UPDATE, REPLACE or DELETE
function __mysql_is_affecting_method ()
{
    local MYSQL_QUERY="$1"

    if [[ "${MYSQL_QUERY}" == ${BP_MYSQL_INSERT}* || "${MYSQL_QUERY}" == ${BP_MYSQL_UPDATE}* || \
          "${MYSQL_QUERY}" == ${BP_MYSQL_REPLACE}* || "${MYSQL_QUERY}" == ${BP_MYSQL_DELETE}* \
    ]]; then
        return 0
    fi

    return 1
}

##
# @returnStatus 1 If query method is not SELECT, SHOW, DESCRIBE or EXPLAIN
function __mysql_is_selecting_method ()
{
    local MYSQL_QUERY="$1"

    if [[ "${MYSQL_QUERY}" == ${BP_MYSQL_SELECT}* || "${MYSQL_QUERY}" == ${BP_MYSQL_SHOW}* || \
          "${MYSQL_QUERY}" == ${BP_MYSQL_DESC}* || "${MYSQL_QUERY}" == ${BP_MYSQL_EXPLAIN}* \
    ]]; then
        return 0
    fi

    return 1
}

##
# Calculate and return a checksum for the query
# @param string $1 String
# @return string
# @returnStatus 1 If first parameter named string is empty
# @returnStatus If checkum is empty or cksum methods returns in error
function __mysql_checksum ()
{
    local MYSQL_CHECKSUM="$1"
    if [[ -z "${MYSQL_CHECKSUM}" ]]; then
        return 1
    fi

    # Create temporary file to apply checksum function on it
    local MYSQL_CHECKSUM_FILE="${BP_MYSQL_WRK_DIR}/${RANDOM}.crc"
    echo -n "${MYSQL_CHECKSUM}" > "${MYSQL_CHECKSUM_FILE}"

    MYSQL_CHECKSUM="$(cksum "${MYSQL_CHECKSUM_FILE}" | awk '{print $1}')"
    if [[ $? -ne 0 || -z "${MYSQL_CHECKSUM}" ]]; then
        return 1
    fi
    # Clean workspace
    rm -f "${MYSQL_CHECKSUM_FILE}"

    echo -n "${MYSQL_CHECKSUM}"
}

##
# Performs a query on the database and return results in variable named in first parameter
# @param int Database link
# @param string Query
# @param string Options
# @return int Result link (only in case of non DML queries)
# @returnStatus 1 If first parameter named query is empty
# @returnStatus 1 If database's host is unknown
# @returnStatus 1 If query failed
function __mysql_query ()
{
    local MYSQL_CHECKSUM="$1"
    local MYSQL_CONNECT_FILE="${BP_MYSQL_WRK_DIR}/${MYSQL_CHECKSUM}${BP_MYSQL_CONNECT_EXT}"
    if [[ ${BP_MYSQL} -eq 0 || -z "${MYSQL_CHECKSUM}" || ! -f "${MYSQL_CONNECT_FILE}" ]]; then
        return 1
    else
        declare -a MYSQL_LINK
        mapfile MYSQL_LINK < "${MYSQL_CONNECT_FILE}"
        if [[ $? -ne 0 ]]; then
            return 1
        fi
    fi
    local MYSQL_QUERY="$2"
    if [[ -z "${MYSQL_QUERY}" ]]; then
        return 1
    fi
    local MYSQL_OPTIONS="$3"
    if [[ -n "${MYSQL_LINK[${BP_MYSQL_PASS}]}" ]]; then
        # Manage empty password
        MYSQL_OPTIONS+=" --password=\"${MYSQL_LINK[${BP_MYSQL_PASS}]}\""
    fi
    if [[ "${MYSQL_LINK[${BP_MYSQL_TO}]}" -gt 0 ]]; then
        # Connect timeout
        MYSQL_OPTIONS+=" --connect_timeout=${MYSQL_LINK[${BP_MYSQL_TO}]}"
    fi
    MYSQL_OPTIONS+=" --host=\"${MYSQL_LINK[${BP_MYSQL_HOST}]}\""
    MYSQL_OPTIONS+=" --user=\"${MYSQL_LINK[${BP_MYSQL_USER}]}\""

    local MYSQL_QUERY_CHECKSUM=$(__mysql_checksum "${MYSQL_CHECKSUM}${BP_MYSQL_CHK_SEP}${MYSQL_QUERY}")
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    local MYSQL_AFFECTED_ROW_FILE="${BP_MYSQL_WRK_DIR}/${MYSQL_CHECKSUM}${BP_MYSQL_AFFECTED_ROW_EXT}"
    local MYSQL_QUERY_RESULT_FILE="${BP_MYSQL_WRK_DIR}/${MYSQL_QUERY_CHECKSUM}${BP_MYSQL_RESULT_EXT}"
    if [[ -f "${MYSQL_QUERY_RESULT_FILE}" && "${MYSQL_LINK[${BP_MYSQL_CACHED}]}" -eq 1 ]]; then
        # Query already in cache
        echo -n "${MYSQL_QUERY_CHECKSUM}"
        return 0
    fi

    local MYSQL_METHOD
    if __mysql_is_affecting_method "${MYSQL_QUERY}"; then
        MYSQL_METHOD=${BP_MYSQL_AFFECTING_METHOD}
        # Add ROW_COUNT query to known the number of affected rows
        MYSQL_QUERY+="${BP_MYSQL_AFFECTED_ROW_COUNT}"
    elif __mysql_is_selecting_method "${MYSQL_QUERY}"; then
        MYSQL_METHOD=${BP_MYSQL_SELECTING_METHOD}
    else
        MYSQL_METHOD=${BP_MYSQL_UNKNOWN_METHOD}
    fi

    local MYSQL_RESULT
    MYSQL_RESULT=$(mysql ${MYSQL_OPTIONS} ${MYSQL_LINK["${BP_MYSQL_DB}"]} -e "${MYSQL_QUERY}" 2>&1)
    if [[ $? -ne 0 ]]; then
        # An error occured
        echo "${MYSQL_RESULT}" > "${BP_MYSQL_WRK_DIR}/${MYSQL_CHECKSUM}${BP_MYSQL_ERROR_EXT}"
        return 1
    elif [[ ${MYSQL_METHOD} -eq ${BP_MYSQL_AFFECTING_METHOD} ]]; then
        # Extract result of the last query to get affected row count
        echo "${MYSQL_RESULT}" | tail -n 1 > "${MYSQL_AFFECTED_ROW_FILE}"
    elif [[ ${MYSQL_METHOD} -eq ${BP_MYSQL_SELECTING_METHOD} ]]; then
        if [[ "${MYSQL_OPTIONS}" == *"${BP_MYSQL_COLUMN_NAMES_OPTS}"* ]]; then
            echo "${MYSQL_RESULT}" > "${MYSQL_QUERY_RESULT_FILE}"
        else
            # Extract header with columns names in dedicated file
            echo "${MYSQL_RESULT}" | head -n 1 > "${BP_MYSQL_WRK_DIR}/${MYSQL_QUERY_CHECKSUM}${BP_MYSQL_COLUMN_NAMES_EXT}"
            # Keep only datas
            echo "${MYSQL_RESULT}" | sed 1d > "${MYSQL_QUERY_RESULT_FILE}"
        fi
        echo -n "${MYSQL_CHECKSUM}${MYSQL_QUERY_CHECKSUM}"
    fi
}

##
# Convert tabulated string values to indexed array
# @return string
function __mysql_fetch_array ()
{
    local MYSQL_QUERY_CHECKSUM="$1"
    local MYSQL_SRC_FILE="${BP_MYSQL_WRK_DIR}/${MYSQL_QUERY_CHECKSUM}${BP_MYSQL_RESULT_EXT}"
    local MYSQL_DST_FILE="${BP_MYSQL_WRK_DIR}/${MYSQL_QUERY_CHECKSUM}-${BP_MYSQL_RESULT_NUM}${BP_MYSQL_RESULT_EXT}"

    if [[ ! -f "${MYSQL_DST_FILE}" ]]; then
        awk 'BEGIN { FS="\x09" }
        {
            printf("(")
            for (i=1;i<=NF;i++) {
                printf("[%d]=\"%s\" ", (i-1), $i)
            }
            printf(")\n")
        }' "${MYSQL_SRC_FILE}" > "${MYSQL_DST_FILE}"
    fi

    cat "${MYSQL_DST_FILE}"
}

##
# Convert tabulated string values to associative array
# @return string
function __mysql_fetch_assoc ()
{
    local MYSQL_QUERY_CHECKSUM="$1"
    local MYSQL_SRC_FILE="${BP_MYSQL_WRK_DIR}/${MYSQL_QUERY_CHECKSUM}${BP_MYSQL_RESULT_EXT}"
    local MYSQL_NMS_FILE="${BP_MYSQL_WRK_DIR}/${MYSQL_QUERY_CHECKSUM}${BP_MYSQL_COLUMN_NAMES_EXT}"
    local MYSQL_DST_FILE="${BP_MYSQL_WRK_DIR}/${MYSQL_QUERY_CHECKSUM}-${BP_MYSQL_RESULT_NUM}${BP_MYSQL_RESULT_EXT}"

    if [[ ! -f "${MYSQL_DST_FILE}" ]]; then
        awk 'BEGIN { FS="\x09" }
        {
            printf("(")
            for (i=1;i<=NF;i++) {
                printf("[%d]=\"%s\" ", (i-1), $i)
            }
            printf(")\n")
        }' "${MYSQL_SRC_FILE}" > "${MYSQL_DST_FILE}"
    fi

    cat "${MYSQL_DST_FILE}"
}

##
# Registry to save connection informations to a mysql server
# @param string $1 Host
# @param string $2 Username
# @param string $3 password
# @param string $4 Database
# @param int $5 Connect timeout
# @param int $6 Cache enabled
# @return int Database link
# @returnStatus 2 If mysql command line tool is not available
# @returnStatus 1 If host, username or database named are empty
function mysqlConnect ()
{
    if [[ ${BP_MYSQL} -eq 0 ]]; then
        # Mysql as command line is required
        return 2
    elif [[ -z "$1" || -z "$2" || -z "$4" ]]; then
        # Only password can be empty (usefull for local access on unsecure database)
        return 1
    fi
    declare -i TO=0
    if [[ -n "$5" ]]; then
        TO="$5"
    fi
    declare -i CACHED=0
    if [[ -n "$6" ]]; then
        CACHED="$6"
    fi

    # Create workspace directory
    if [[ ! -d "${BP_MYSQL_WRK_DIR}" ]]; then
        mkdir -p "${BP_MYSQL_WRK_DIR}"
    fi

    # Create connection
    local MYSQL_CHECKSUM=$(__mysql_checksum "${1}${BP_MYSQL_CHK_SEP}${2}${BP_MYSQL_CHK_SEP}${3}${BP_MYSQL_CHK_SEP}${4}")
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    echo -e "${1}\n${2}\n${3}\n${4}\n${TO}\n${CACHED}" > "${BP_MYSQL_WRK_DIR}/${MYSQL_CHECKSUM}${BP_MYSQL_CONNECT_EXT}"

    echo -n "${MYSQL_CHECKSUM}"
}

##
# Gets the number of affected rows in a previous MySQL operation
# Returns the number of rows affected by the last INSERT, UPDATE, REPLACE or DELETE query.
# @param string $1 Database Link
# @return int
# @returnStatus 1 If result link does not exist
function mysqlAffectedRows ()
{
    local MYSQL_CHECKSUM="$1"
    local MYSQL_AFFECTED_ROW_FILE="${BP_MYSQL_WRK_DIR}/${MYSQL_CHECKSUM}${BP_MYSQL_AFFECTED_ROW_EXT}"
    if [[ -z "${MYSQL_CHECKSUM}" || ! -f "${MYSQL_AFFECTED_ROW_FILE}" ]]; then
        return 1
    fi

    cat "${MYSQL_AFFECTED_ROW_FILE}"
}

##
# Clean workspace of opened database connections and results
# @param int $1 Database link
# @returnStatus 1 If workspace does not exist
function mysqlClose ()
{
    local MYSQL_CHECKSUM="$1"
    local MYSQL_CONNECT_FILE="${BP_MYSQL_WRK_DIR}/${MYSQL_CHECKSUM}${BP_MYSQL_CONNECT_EXT}"
    if [[ -z "${MYSQL_CHECKSUM}" || ! -f "${MYSQL_CONNECT_FILE}" ]]; then
        return 1
    fi

    # Remove connection file
    rm -f "${MYSQL_CONNECT_FILE}"
    # Remove all result files
    rm -f "${BP_MYSQL_WRK_DIR}/${MYSQL_CHECKSUM}*${BP_MYSQL_RESULT_EXT}"
    # Remove last error file
    rm -f "${BP_MYSQL_WRK_DIR}/${MYSQL_CHECKSUM}${BP_MYSQL_ERROR_EXT}"
}

##
# Returns a string description of the last error
# @param int Database link
# @return string
function mysqlLastError ()
{
    local MYSQL_CHECKSUM="$1"
    local MYSQL_ERROR_FILE="${BP_MYSQL_WRK_DIR}/${MYSQL_CHECKSUM}${BP_MYSQL_ERROR_EXT}"
    if [[ -f "${MYSQL_ERROR_FILE}" ]]; then
        cat "${MYSQL_ERROR_FILE}"
    fi
}

##
# Escapes special characters in a string for use in an SQL statement
# Characters encoded are NUL (ASCII 0), \n, \r, \, ', "
# @param string $1 Var
# @return string
function mysqlEscapeString ()
{
    echo -n "$1" | sed -e "s/\\\/\\\\/g" -e 's/"/\\"/g' -e "s/'/\\\'/g" -e "s/\\x00/\\\'/g" -e "s/\\n/\\\n/g"
}

##
# Fetches all result rows as an associative array, a numeric array, or raw (csv with tabs)
# @param string $1 Result link
# @param string $2 Query
# @param string $3 Result mode, numeric index as default mode
# @return string
# @returnStatus 1 If first parameter named query is empty
# @returnStatus 1 If database's host is unknown
# @returnStatus 1 If query failed
function mysqlFetchAll ()
{
    local MYSQL_CHECKSUM="$1"
    local MYSQL_QUERY="$2"
    local MYSQL_RESULT_MODE="$3"
    local MYSQL_OPTIONS
    case "${MYSQL_RESULT_MODE}" in
        ${BP_MYSQL_RESULT_ASSOC}) MYSQL_OPTIONS=${BP_MYSQL_OPTS} ;;
        *) MYSQL_OPTIONS=${BP_MYSQL_BASIC_OPTS} ;;
    esac

    local MYSQL_QUERY_CHECKSUM
    MYSQL_QUERY_CHECKSUM=$(__mysql_query "${MYSQL_CHECKSUM}" "${MYSQL_QUERY}" "${MYSQL_OPTIONS}")
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    case "${MYSQL_RESULT_MODE}" in
        ${BP_MYSQL_RESULT_RAW}) cat "${BP_MYSQL_WRK_DIR}/${MYSQL_QUERY_CHECKSUM}${BP_MYSQL_RESULT_EXT}" ;;
        ${BP_MYSQL_RESULT_ASSOC}) __mysql_fetch_assoc "${MYSQL_QUERY_CHECKSUM}" ;;
        ${BP_MYSQL_RESULT_NUM}|*) __mysql_fetch_array "${MYSQL_QUERY_CHECKSUM}" ;;
    esac
}

##
# Fetch a result row as an associative array
# @param string $1 Result link
# @param string $2 Query
# @return string
# @returnStatus 1 If first parameter named query is empty
# @returnStatus 1 If database's host is unknown
# @returnStatus 1 If query failed
function mysqlFetchAssoc ()
{
    local MYSQL_CHECKSUM="$1"
    local MYSQL_QUERY="$2"

    mysqlFetchAll "${MYSQL_CHECKSUM}" "${MYSQL_QUERY}" "${BP_MYSQL_RESULT_ASSOC}"
    return $?
}

##
# Get a result row as an enumerated array
# @param string $1 Result link
# @param string $2 Query
# @return string
# @returnStatus 1 If first parameter named query is empty
# @returnStatus 1 If database's host is unknown
# @returnStatus 1 If query failed
function mysqlFetchArray ()
{
    local MYSQL_CHECKSUM="$1"
    local MYSQL_QUERY="$2"

    mysqlFetchAll "${MYSQL_CHECKSUM}" "${MYSQL_QUERY}" "${BP_MYSQL_RESULT_NUM}"
    return $?
}

##
# Gets the number of rows in a result
# @param string $1 Result Link
# @return int
# @returnStatus 1 If result link does not exist
function mysqlNumRows ()
{
    local MYSQL_QUERY_CHECKSUM="$1"
    local MYSQL_QUERY_RESULT_FILE="${BP_MYSQL_WRK_DIR}/${MYSQL_QUERY_CHECKSUM}${BP_MYSQL_RESULT_EXT}"
    if [[ -z "${MYSQL_QUERY_CHECKSUM}" || ! -f "${MYSQL_QUERY_RESULT_FILE}" ]]; then
        return 1
    fi

    echo -n $(wc -l < "${MYSQL_QUERY_RESULT_FILE}")
}

##
# Set options
# @param int Database link
# @param int $2 Option
# @param mixed $3 Value
# @returnStatus 1 If link does not exist
# @returnStatus 1 If option does not exist
function mysqlOption ()
{
    local MYSQL_CHECKSUM="$1"
    local MYSQL_CONNECT_FILE="${BP_MYSQL_WRK_DIR}/${MYSQL_CHECKSUM}${BP_MYSQL_CONNECT_EXT}"
    if [[ -z "${MYSQL_CHECKSUM}" || ! -f "${MYSQL_CONNECT_FILE}" ]]; then
        return 1
    fi

    local MYSQL_OPTION="$2"
    case "${MYSQL_OPTION}" in
        ${BP_MYSQL_TO})
            declare -i CONNECT_TIMEOUT="$3"
            sed -i "${BP_MYSQL_TO}s/.*/${CONNECT_TIMEOUT}/" "${MYSQL_CONNECT_FILE}"
            ;;
        ${BP_MYSQL_CACHED})
            declare -i CACHED="$3"
            sed -i "${BP_MYSQL_CACHED}s/.*/${CACHED}/" "${MYSQL_CONNECT_FILE}"
            ;;
        *) return 1 ;;
    esac
}

##
# Performs a query on the database
# @param string $1 Database link
# @param string $2 Query
# @return int Result link (only in case of non DML queries)
# @returnStatus 1 If first parameter named query is empty
# @returnStatus 1 If database's host is unknown
# @returnStatus 1 If query failed
function mysqlQuery ()
{
    local MYSQL_CHECKSUM="$1"
    local MYSQL_QUERY="$2"

    __mysql_query "${MYSQL_CHECKSUM}" "${MYSQL_QUERY}" "${BP_MYSQL_BASIC_OPTS}"
    return $?
}