#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Function to handle termination signals
_term() {
    echo "Caught termination signal! Stopping processes..."
    kill -TERM "$TWISTD_PID" 2>/dev/null
    exit 0
}

trap _term SIGTERM SIGINT

# Variables
STATIC_PORT=${STATIC_PORT:-8000}
DATA_DIR=${DATA_DIR:-data}

# Start the Twisted web server in the background
twistd -n web --path "$DATA_DIR" --port "tcp:$STATIC_PORT" &
TWISTD_PID=$!

echo "Started Twisted web server on port $STATIC_PORT serving directory $DATA_DIR with PID $TWISTD_PID"

# Start your main application
python mylocal_service.py "$@"

# Wait for the main application to exit
APP_EXIT_CODE=$?

# Kill the Twisted web server
kill -TERM "$TWISTD_PID" 2>/dev/null

# Exit with the same code as the main application
exit $APP_EXIT_CODE
