#!/bin/bash
# Church Presentation App startup script
# Local network deployment for macOS/Linux

set -e
cd "$(dirname "$0")"

PY="${PYTHON:-python3}"
if ! "$PY" -c 'import sys; sys.exit(sys.version_info < (3, 11))'; then
    echo "Python 3.11+ required (found: $("$PY" --version 2>&1)). Set PYTHON=/path/to/python3.x"
    exit 1
fi

if [ ! -d .venv ]; then
    echo "Creating virtual environment..."
    "$PY" -m venv .venv
fi

echo "Installing Python dependencies..."
.venv/bin/pip install -q -r requirements.txt

echo "Starting Python server..."
exec .venv/bin/python src/server/server.py
