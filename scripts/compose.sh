#!/bin/sh
# Resolves the compose command and refuses to continue without a .env. Sourced by
# start.sh, down.sh and restart.sh — all of them cd into scripts/ first, so .env and
# docker-compose.yml are in the current directory. Sourced rather than executed, so
# the `exit` below terminates the calling script; do not source it interactively.

if [ ! -f .env ]; then
    echo
    echo "===== ERROR: scripts/.env not found ====="
    echo
    echo "Create it from the template and fill it in:"
    echo
    echo "    cp scripts/.env.example scripts/.env"
    echo
    echo "Then set at least MCP_INSPECTOR_UI_PASSWORD and MCP_INSPECTOR_API_TOKEN."
    echo
    exit 1
fi

if docker compose version >/dev/null 2>&1; then
    COMPOSE="docker compose -f docker-compose.yml"
else
    echo
    echo "===== ERROR: docker compose not found ====="
    echo
    echo "Install Docker Compose v2 (the 'docker compose' subcommand)."
    echo
    exit 1
fi
