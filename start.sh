#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Function to handle termination signals
_term() {
    echo "Caught termination signal! Stopping processes..."
    kill -TERM "$HTTP_SERVER_PID" 2>/dev/null
    exit 0
}

trap _term SIGTERM SIGINT

# Variables
STATIC_PORT=${STATIC_PORT:-8000}
DATA_DIR=${DATA_DIR:-data}

# Start the http.server to serve files from the data directory in the background
python3 -m http.server "$STATIC_PORT" --directory "$DATA_DIR" &

HTTP_SERVER_PID=$!

echo "Started http.server on port $STATIC_PORT serving directory $DATA_DIR with PID $HTTP_SERVER_PID"

# Start your main application
python mylocal_service.py "$@"

# Wait for the main application to exit
APP_EXIT_CODE=$?

# Optionally, you can kill the HTTP server if you want it to stop when your app exits
kill -TERM "$HTTP_SERVER_PID" 2>/dev/null

# Exit with the same code as the main application
exit $APP_EXIT_CODE
