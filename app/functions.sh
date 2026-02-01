#!/bin/bash

# Get HTTP Status Code using CURL
function curl_http_status_code() {
    # Input Arguments
    local ltarget="$1"

    # Get HTTP Status Code
    local lstatus_code
    local lreturn_code
    lstatus_code=$(curl -s -o /dev/null -w "%{http_code}" "${ltarget}")
    lreturn_code=$?

    # Return Value
    echo ${lstatus_code}

    # Return Status Code
    return ${lreturn_code}
}
