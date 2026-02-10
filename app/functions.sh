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
    lstatus_code=$(curl -L -s -o /dev/null ${largs[*]} -w "%{http_code}" "${ltarget}" | return_value)
    lreturn_code=$?

    # Display Error if any
    if [[ ${lstatus_code} -ne 0 ]]
    then
        # Error
        log_error "Error occurred when querying ${ltarget}."
        log_error "CURL exited with Exit Code ${lreturn_code}. HTTP Status Code was ${lstatus_code}."
    else
        # Debug
        log_debug "CURL exited with Exit Code ${lreturn_code}. HTTP Status Code was ${lstatus_code}."
    fi

    # Return Value
    return_value "${lstatus_code}"

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

# Initialize Custom File Descriptor
# https://unix.stackexchange.com/a/218355
function open_fd() {
    # Input Parameters
    local lfd="$1"

    if [[ ! -e "/dev/fd/${lfd}" ]]
    then
        # Open File Descriptor (show Output)
        # eval "exec ${lfd}>&1"

        # Open File Descriptor (hide Output)
        eval "exec ${lfd}> /dev/null"
    fi
}

# Close Custom File Descriptor
function close_fd() {
    # Input Parameters
    local lfd="$1"

    if [[ -e "/dev/fd/${lfd}" ]]
    then
        # Close File Descriptor
        eval "exec ${lfd}>&-"
    fi
}

# Return Value
function return_value() {
    # Input Arguments
    local lvalue

    # Open File Descriptor
    open_fd 3

    # Try to get Input from HereDoc
    mapfile -t lvalue < <( timeout 0.5 bash -c "cat /dev/stdin" )

    if [[ -z "${lvalue}" ]]
    then
        # If no Lines are Read from stdin, take Value from first Argument ($1)
        lvalue="$1"
    else
        # Nothing to do
        local lx=0
    fi

    # Return Value
    echo "${lvalue}" 3>&1 >&3

    # Close File Descriptor
    close_fd 3
}

# Logging (General)
function log_message() {
    # Input Arguments
    local llevel="$1"
    local lmessage=${*:2}

    # Format Message
    local lformatted_message="[${llevel}]: ${lmessage}"

    if [[ "${HEALTH_OUTPUT_STREAM}" == *"stderr"* ]]
    then
        # Write to stderr
        echo "${lformatted_message}" >&2
    fi

    if [[ "${HEALTH_OUTPUT_STREAM}" == *"stdout"* ]]
    then
        # Write to stdout
        echo "${lformatted_message}"
    fi
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
