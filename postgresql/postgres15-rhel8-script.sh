#!/bin/bash
set -e

if [ -n "$CUSTOM_SQL_SCRIPT" ]; then
    psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" <<<"$CUSTOM_SQL_SCRIPT"
else
    echo "CUSTOM_SQL_SCRIPT is empty. No action taken."
fi
