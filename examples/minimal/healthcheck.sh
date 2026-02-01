#!/bin/bash

# Abort on Error
set -e

# Check that HTTP Status Code is 200
http_status_code=$(curl_http_status_code "https://${APPLICATION_HOSTNAME}")
curl_return_code=$?

if [[ ${http_status_code} -ne 200 ]]
then
    # Exit abnormally
    exit 1
fi

# Exit Normally
exit 0
