#!/bin/bash

# Set default Blanking Time
if [[ ! -v HEALTH_START_PERIOD ]]
then
    # Set Value
    HEALTH_START_PERIOD=60

    # Debug
    log_info "Setting Variable HEALTH_START_PERIOD to ${HEALTH_START_PERIOD} (Default Value)"
fi

# Set default Health Check Interval
if [[ ! -v HEALTH_INTERVAL ]]
then
    # Set Value
    HEALTH_INTERVAL=30

    # Debug
    log_info "Setting Variable HEALTH_INTERVAL to ${HEALTH_INTERVAL} (Default Value)"
fi

# Set default Health Check Retries
if [[ ! -v HEALTH_RETRIES ]]
then
    # Set Value
    HEALTH_RETRIES=5

    # Debug
    log_info "Setting Variable HEALTH_RETRIES to ${HEALTH_RETRIES} (Default Value)"
fi

# Default Health Check Script
if [[ ! -v HEALTH_CMD ]]
then
    # Set Value
    HEALTH_CMD="/healthcheck.sh"

    # Debug
    log_info "Setting Variable HEALTH_CMD to ${HEALTH_CMD} (Default Value)"
fi

# Default Health Debug Setting
if [[ ! -v HEALTH_DEBUG ]]
then
    # Set Value
    HEALTH_DEBUG=0

    # Debug
    log_info "Setting Variable HEALTH_DEBUG to ${HEALTH_DEBUG} (Default Value)"
fi


