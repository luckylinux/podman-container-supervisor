#!/bin/bash

# Set default Blanking Time
if [[ ! -v HEALTH_START_PERIOD ]]
then
    HEALTH_START_PERIOD=60
fi

# Set default Health Check Interval
if [[ ! -v HEALTH_INTERVAL ]]
then
    HEALTH_INTERVAL=30
fi

# Set default Health Check Retries
if [[ ! -v HEALTH_RETRIES ]]
then
    HEALTH_RETRIES=5
fi

# Default Health Check Script
if [[ ! -v HEALTH_CMD ]]
then
    HEALTH_CMD="/healthcheck.sh"
fi

