#!/bin/bash
set -e

TEMPLATE="/etc/mysql/init.temp.sql"
OUTPUT="/etc/mysql/init.sql"

# Load Docker secrets for passwords if present
if [ -f /run/secrets/db_root_password ]; then
    export DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
fi

if [ -f /run/secrets/db_user_password ]; then
    export DB_USER_PASSWORD="$(cat /run/secrets/db_user_password)"
fi

# Ensure template exists
if [ ! -f "$TEMPLATE" ]; then
    echo "[!] Missing template: $TEMPLATE" >&2
    exit 1
fi

# Replace only the variables used by init.sql
# (DB_DATABASE and DB_USER_NAME are expected to come from the environment / docker env_file)
envsubst '$DB_DATABASE $DB_ROOT_PASSWORD $DB_USER_NAME $DB_USER_PASSWORD' < "$TEMPLATE" > "$OUTPUT"

echo "[+] Generated $OUTPUT"
