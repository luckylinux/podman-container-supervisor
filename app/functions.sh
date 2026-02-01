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
