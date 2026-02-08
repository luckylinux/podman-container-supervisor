#!/bin/bash

# Get HTTP Status Code using CURL
function curl_http_status_code() {
    # Input Arguments
    local ltarget="$1"
    local lopts=${2-""}

    # Debug
    log_debug "Perform CURL Request to ${ltarget}"

    # CURL does NOT support Empty Arguments, thus make sure that there is actually something there
    local largs
    largs=()
    if [[ -n "${lopts}" ]]
    then
        largs+=("${lopts}")
    fi

    # Get HTTP Status Code
    local lstatus_code
    local lreturn_code
    lstatus_code=$(curl -L -s -o /dev/null ${largs[*]} -w "%{http_code}" "${ltarget}")
    lreturn_code=$?

    # Debug
    log_debug "CURL exited with Exit Code ${lreturn_code}. HTTP Status Code was ${lstatus_code}."

    # Return Value
    echo "${lstatus_code}"

    # Return Status Code
    return ${lreturn_code}
}

# Is reachable over HTTP
function is_http_reachable() {
    # Input Arguments
    local ltarget="$1"
    local lopts=${2-""}

    # Initialize Local Variables
    local lstatus
    local lreturn_code
    lstatus="ERROR"
    lreturn_code=99

    # Perform HTTP Request
    http_status_code=$(curl_http_status_code "${ltarget}" "${lopts}")
    curl_return_code=$?

    if [[ ${curl_return_code} -eq 0 ]]
    then
        # Check if Valid HTTP Response
        case "${http_status_code}" in

            # Valid HTTP Status Codes: 200, 304
            "200" | "304" )
                lstatus="OK"
                lreturn_code=0 ;;

            # HTTP Status Codes that indicate a Failure
            *)
                lstatus="ERROR"
                lreturn_code=1 ;;
        esac
    else
        # Set Status Code same as CURL
        lstatus="ERROR"
        lreturn_code=${curl_return_code}
    fi

    # Return Status Code
    return ${lreturn_code}
}

# Is reachable over HTTP (IPv4)
function is_http_reachable_ipv4() {
    # Input Arguments
    local ltarget="$1"

    # Run Generic Function
    is_http_reachable "${ltarget}" "-4"
}

# Is reachable over HTTP (IPv6)
function is_http_reachable_ipv6() {
    # Input Arguments
    local ltarget="$1"

    # Run Generic Function
    is_http_reachable "${ltarget}" "-6"
}

# Check PING (IPv4)
function is_pingable_ipv4() {
    # Input Arguments
    local ltarget="$1"

    # Pre-declare Variable
    local lreturn_code

    # Ping using IPv4
    ping -c4 -i 0.2 -w 1 -4 "${ltarget}" > /dev/null

    # Store Exit Code
    lreturn_code=$?

    if [[ ${lreturn_code} -ne 0 ]]
    then
        # Log Error
        log_error "PING Error: ${ltarget} couldn't be reached"
    fi

    # Return Code
    return ${lreturn_code}
}

# Check PING (IPv6)
function is_pingable_ipv6() {
    # Input Arguments
    local ltarget="$1"

    # Pre-declare Variable
    local lreturn_code

    # Ping using IPv6
    ping -c4 -i 0.2 -w 1 -6 "${ltarget}" > /dev/null

    # Store Exit Code
    lreturn_code=$?

    if [[ ${lreturn_code} -ne 0 ]]
    then
        # Log Error
        log_error "PING Error: ${ltarget} couldn't be reached"
    fi

    # Return Code
    return ${lreturn_code}
}

# Check PING (Any)
function is_pingable_any() {
    # Input Arguments
    local ltarget="$1"

    # Pre-declare Variable
    local lreturn_code

    # Ping using IPv4
    is_pingable_ipv4 "${ltarget}"

    # Store Exit Code
    lreturn_code=$?

    if [[ ${lreturn_code} -ne 0 ]]
    then
        # Ping using IPv6
        is_pingable_ipv6 "${ltarget}"

        # Store Exit Code
        lreturn_code=$?

        if [[ ${lreturn_code} -ne 0 ]]
        then
            # Log Error
            log_error "PING Error: ${ltarget} couldn't be reached"

            # Return
            return ${lreturn_code}
        fi
    fi

    # Return Code
    return ${lreturn_code}
}

# Check PING (IPv4 + IPv6)
function is_pingable_dual() {
    # Input Arguments
    local ltarget="$1"

    # Pre-declare Variable
    local lreturn_code

    # Ping using IPv4
    is_pingable_ipv4 "${ltarget}"

    # Store Exit Code
    lreturn_code=$?

    if [[ ${lreturn_code} -eq 0 ]]
    then
        # Ping using IPv6
        is_pingable_ipv6 "${ltarget}"

        # Store Exit Code
        lreturn_code=$?

        if [[ ${lreturn_code} -eq 0 ]]
        then
            # Return
            return ${lreturn_code}
        fi
    fi

    # Log Error
    log_error "PING Error: ${ltarget} couldn't be reached"

    # Return Status Code
    return ${lreturn_code}
}

# Check if TCP Port is listening
function is_tcp_listening() {
    # Input Arguments
    local lport="$1"

    # Pre-declare Variable
    local lreturn_code

    # Check if TCP Port is listening
    bash -c "</dev/tcp/localhost/${lport}"

    # Store Exit Code
    lreturn_code=$?

    if [[ ${lreturn_code} -ne 0 ]]
    then
        # Print Warning
        log_error "TCP Port ${lport} is not listening"
    fi

    # Return Code
    return ${lreturn_code}
}

# Logging (General)
function log_message() {
    # Input Arguments
    local llevel="$1"
    local lmessage=${*:2}

    # Format Message
    local lformatted_message="[${llevel}]: ${lmessage}"

    # Echo to stderr
    echo "${lformatted_message}" >&2

    # Echo to stdout
    # echo "${lformatted_message}"
}

# Logging (Info)
function log_info() {
    log_message "INFO" "$@"
}

# Logging (Warning)
function log_warn() {
    log_message "WARN" "$@"
}

# Logging (Error)
function log_error() {
    log_message "ERROR" "$@"
}

# Logging (Debug)
function log_debug() {
    # Must be explicitely enabled by setting CONTAINER_DEBUG to >= 1
    if [ "${HEALTH_DEBUG:-0}" -ge 1 ]
    then
        log_message "DEBUG" "$@"
    fi
}
