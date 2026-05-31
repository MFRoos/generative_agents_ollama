#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"

# Apply any pending migrations
cd "$ROOT/environment/frontend_server"
python manage.py migrate --run-syncdb -v 0

# Start the environment server in the background
echo "Starting environment server at http://localhost:8000 ..."
python manage.py runserver &
ENV_PID=$!

# Give Django a moment to boot
sleep 2

# Kill the environment server when this script exits
trap "echo 'Stopping environment server...'; kill $ENV_PID 2>/dev/null" EXIT

# Start the simulation server in the foreground
echo "Starting simulation server..."
cd "$ROOT/reverie/backend_server"
python reverie.py
