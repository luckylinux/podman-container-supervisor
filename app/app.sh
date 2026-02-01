#!/bin/bash

# Set HEALTH_CHECK_PATH
HEALTH_CHECK_PATH="/opt/supervisor"

# Change to app folder
cd "/opt/supervisor" || exit

# Include Libraries
source "${HEALTH_CHECK_PATH}/functions.sh"

# Set Default Values
source "${HEALTH_CHECK_PATH}/defaults.sh"

# Echo
log_info "Wait ${HEALTH_START_PERIOD} Seconds to allow Time for Applications to be Monitored to be started"

# Initial Blanking Period
sleep ${HEALTH_START_PERIOD}

# Initialize Counter
health_failed_counter=0

# Infinite Loop
log_info "Start Supervisor Infinite Loop"
while true
do
    # Execute Health Check
    ${HEALTH_CMD}

    # Save Exit Code
    health_exit_code=$?

    if [[ ${health_exit_code} -ne 0 ]]
    then
        # Error
        log_error "Health Check exited with Exit Code ${health_exit_code}. Health Check Failed Counter is now ${health_failed_counter}."

        # Increase Counter
        health_failed_counter=$((health_failed_counter+1))
    else
        if ${health_failed_counter} -ne 0 ]]
        then
            # Info
            log_info "Health Check exited with Exit Code ${health_exit_code}. Health Check Failed Counter will now be resetted."

            # Reset Counter
            health_failed_counter=0
        fi

        # Debug
        log_debug "Health Check completed successfully"

    fi

    # Check if Health Check exceeded Maximum Number of Attempts
    if [[ ${health_failed_counter} -ge ${HEALTH_RETRIES} ]]
    then
        # Exit with abnormal Exit Code
        exit ${health_exit_code}
    fi

    # Wait
    sleep ${HEALTH_INTERVAL}
done
