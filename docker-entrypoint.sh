#!/bin/bash

# Change to /opt/supervisor Folder
cd /opt/supervisor

# Start the main Process and save its PID
# Use exec to replace the Shell Script Process with the main Process
exec /opt/supervisor/app.sh &
pidh=$!

# Trap the SIGTERM signal and forward it to the main process
trap 'kill -SIGTERM $pidh; wait $pidh' SIGTERM

# Wait for the main process to complete
wait $pidh
