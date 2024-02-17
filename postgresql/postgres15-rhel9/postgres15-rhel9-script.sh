#!/bin/bash

set -e

IFS=',' read -ra USERS <<< "$USERS"
IFS=',' read -ra PASSWORDS <<< "$PASSWORDS"
IFS=',' read -ra DATABASES <<< "$DATABASES"

for ((i=0; i<${#USERS[@]}; i++)); do
    POSTGRESQL_USER="${USERS[$i]}"
    POSTGRESQL_DATABASE="${DATABASES[$i]}"
    POSTGRESQL_USER_PASSWORD="${PASSWORDS[$i]}"
    POSTGRESQL_USER_COMMENT="User Comment for $POSTGRESQL_USER"
    POSTGRESQL_DB_COMMENT="DB Comment for $POSTGRESQL_DATABASE"

    # Check if the user already exists
    psql --username "postgres" --dbname "postgres" -t -c "SELECT 1 FROM pg_roles WHERE rolname='$POSTGRESQL_USER'" || {
        # Create the user if it doesn't exist
        CREATE_USER="CREATE ROLE $POSTGRESQL_USER WITH
                    LOGIN               
                    NOSUPERUSER         
                    NOCREATEDB          
                    NOCREATEROLE        
                    INHERIT             
                    NOREPLICATION       
                    NOBYPASSRLS         
                    CONNECTION LIMIT -1 
                    PASSWORD '$POSTGRESQL_USER_PASSWORD'; "
        psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_USER"
    }

    # Check if the database exists
    psql --username "postgres" --dbname "postgres" -t -c "SELECT 1 FROM pg_database WHERE datname='$POSTGRESQL_DATABASE'" || {
        # Create the database if it doesn't exist
        CREATE_DATABASE="CREATE DATABASE $POSTGRESQL_DATABASE WITH
                         OWNER = $POSTGRESQL_USER
                         ENCODING = 'UTF8'
                         LOCALE_PROVIDER = 'libc'
                         CONNECTION LIMIT = -1
                         IS_TEMPLATE = False;"
        psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_DATABASE"
    }

    # Grant permissions to the user on the database
    GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
                  COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

    psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" <<<"$GRANT_SCRIPT"

    # Comment on the user
    psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
        -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
done