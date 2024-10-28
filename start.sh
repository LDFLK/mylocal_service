#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Function to handle termination signals
_term() {
    echo "Caught termination signal! Stopping processes..."
    kill -TERM "$HTTPD_PID" 2>/dev/null
    exit 0
}

trap _term SIGTERM SIGINT

# Variables
STATIC_PORT=${STATIC_PORT:-8000}
DATA_DIR=${DATA_DIR:-data}

# Start the BusyBox HTTPD server in the background
busybox httpd -f -p $STATIC_PORT -h "$DATA_DIR" &
HTTPD_PID=$!

echo "Started BusyBox HTTPD server on port $STATIC_PORT serving directory $DATA_DIR with PID $HTTPD_PID"

# Start your main application
python mylocal_service.py "$@"

# Wait for the main application to exit
APP_EXIT_CODE=$?

# Kill the BusyBox HTTPD server
kill -TERM "$HTTPD_PID" 2>/dev/null

exit $APP_EXIT_CODE