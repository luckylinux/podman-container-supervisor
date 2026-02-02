#!/bin/bash

# Get HTTP Status Code using CURL
function curl_http_status_code() {
    # Input Arguments
    local ltarget="$1"

    # Debug
    log_debug "Perform CURL Request to ${ltarget}"

    # Get HTTP Status Code
    local lstatus_code
    local lreturn_code
    lstatus_code=$(curl -L -s -o /dev/null -w "%{http_code}" "${ltarget}")
    lreturn_code=$?

    # Debug
    log_debug "CURL exited with Exit Code ${lreturn_code}. HTTP Status Code was ${lstatus_code}."

    # Return Value
    echo "${lstatus_code}"

    # Return Status Code
    return ${lreturn_code}
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
