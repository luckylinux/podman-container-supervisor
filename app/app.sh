#!/bin/bash

# Set HEALTH_CHECK_PATH
HEALTH_CHECK_PATH="/opt/supervisor"

# Change to app folder
cd "/opt/supervisor" || exit

# Include Libraries
source "${HEALTH_CHECK_PATH}/functions.sh"

# Set Default Values
source "${HEALTH_CHECK_PATH}/defaults.sh"

# Check if Health Internal Loop is enabled
# Otherwise it could be that the Container is being monitored using Podman HealthCheck, thus this does NOT need to do anything except sleep

if [[ ${HEALTH_INTERNAL_LOOP} -eq 1 ]]
then
    # Echo
    log_info "Wait ${HEALTH_START_PERIOD} Seconds to allow Time for Applications to be Monitored to be started"

    # Initial Blanking Period
    sleep "${HEALTH_START_PERIOD}"

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
            # Increase Counter
            health_failed_counter=$((health_failed_counter+1))

            # Error
            log_error "Health Check exited with Exit Code ${health_exit_code}. Health Check Failed Counter is now [${health_failed_counter} / ${HEALTH_RETRIES}]."
        else
            if [[ ${health_failed_counter} -ne 0 ]]
            then
                # Reset Counter
                health_failed_counter=0

                # Info
                log_info "Health Check exited with Exit Code ${health_exit_code}. Health Check Failed Counter resetted to [${health_failed_counter} / ${HEALTH_RETRIES}]."
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
        sleep "${HEALTH_INTERVAL}"
    done
else
    # Infinite Sleep Loop
    log_info "Infinite Sleep Loop (HEALTH_INTERNAL_LOOP was set to ${HEALTH_INTERNAL_LOOP})"
    log_info "This Main Application will only wait for external Podman HealthChecks to run and will NOT perform any action internally."

    while true
    do
        sleep 5
    done
fi
