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
    if psql -tqc "\\du $POSTGRESQL_USER" | grep -qw "$POSTGRESQL_USER"; then
        echo "User $POSTGRESQL_USER already exists. Skipping user creation."
        continue
    fi

    # Check if the database already exists
    if psql -tqc "\\l $POSTGRESQL_DATABASE" | grep -qw "$POSTGRESQL_DATABASE"; then
        echo "Database $POSTGRESQL_DATABASE already exists. Skipping database creation."
        continue
    fi

    # Create the user
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

    # Create the database
    CREATE_DATABASE="CREATE DATABASE $POSTGRESQL_DATABASE WITH
                     OWNER = $POSTGRESQL_USER
                     ENCODING = 'UTF8'
                     LOCALE_PROVIDER = 'libc'
                     CONNECTION LIMIT = -1
                     IS_TEMPLATE = False;"
    psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_DATABASE"

    # Grant permissions to the user on the database
    GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
                  COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

    psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$GRANT_SCRIPT"

    # Comment on the user
    psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
        -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
done






# #!/bin/bash

# set -e

# IFS=',' read -ra USERS <<< "$USERS"
# IFS=',' read -ra PASSWORDS <<< "$PASSWORDS"
# IFS=',' read -ra DATABASES <<< "$DATABASES"

# for ((i=0; i<${#USERS[@]}; i++)); do
#     POSTGRESQL_USER="${USERS[$i]}"
#     POSTGRESQL_DATABASE="${DATABASES[$i]}"
#     POSTGRESQL_USER_PASSWORD="${PASSWORDS[$i]}"
#     POSTGRESQL_USER_COMMENT="User Comment for $POSTGRESQL_USER"
#     POSTGRESQL_DB_COMMENT="DB Comment for $POSTGRESQL_DATABASE"

#     # Check if the user already exists
#     USER_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT rolname FROM pg_roles WHERE rolname='$POSTGRESQL_USER'")

#     if [ -n "$USER_EXISTS" ]; then
#         echo "User $POSTGRESQL_USER already exists. Exiting script."
#         exit 1
#     fi

#     # Check if the database already exists
#     DB_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT datname FROM pg_database WHERE datname='$POSTGRESQL_DATABASE'")

#     if [ -n "$DB_EXISTS" ]; then
#         echo "Database $POSTGRESQL_DATABASE already exists. Exiting script."
#         exit 1
#     fi

#     # Create the user
#     CREATE_USER="CREATE ROLE $POSTGRESQL_USER WITH
#                 LOGIN               
#                 NOSUPERUSER         
#                 NOCREATEDB          
#                 NOCREATEROLE        
#                 INHERIT             
#                 NOREPLICATION       
#                 NOBYPASSRLS         
#                 CONNECTION LIMIT -1 
#                 PASSWORD '$POSTGRESQL_USER_PASSWORD'; "

#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_USER"

#     # Create the database
#     CREATE_DATABASE="CREATE DATABASE $POSTGRESQL_DATABASE WITH
#                      OWNER = $POSTGRESQL_USER
#                      ENCODING = 'UTF8'
#                      LOCALE_PROVIDER = 'libc'
#                      CONNECTION LIMIT = -1
#                      IS_TEMPLATE = False;"
#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_DATABASE"

#     # Grant permissions to the user on the database
#     GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
#                   COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$GRANT_SCRIPT"

#     # Comment on the user
#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
#         -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
# done




# #!/bin/bash

# set -e

# IFS=',' read -ra USERS <<< "$USERS"
# IFS=',' read -ra PASSWORDS <<< "$PASSWORDS"
# IFS=',' read -ra DATABASES <<< "$DATABASES"

# for ((i=0; i<${#USERS[@]}; i++)); do
#     POSTGRESQL_USER="${USERS[$i]}"
#     POSTGRESQL_DATABASE="${DATABASES[$i]}"
#     POSTGRESQL_USER_PASSWORD="${PASSWORDS[$i]}"
#     POSTGRESQL_USER_COMMENT="User Comment for $POSTGRESQL_USER"
#     POSTGRESQL_DB_COMMENT="DB Comment for $POSTGRESQL_DATABASE"

#     # Check if the user already exists
#     USER_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_roles WHERE rolname='$POSTGRESQL_USER'" || true)

#     if [ "$USER_EXISTS" == "1" ]; then
#         echo "User $POSTGRESQL_USER already exists. Exiting script."
#         exit 1
#     fi

#     # Check if the database already exists
#     DB_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_database WHERE datname='$POSTGRESQL_DATABASE'" || true)

#     if [ "$DB_EXISTS" == "1" ]; then
#         echo "Database $POSTGRESQL_DATABASE already exists. Exiting script."
#         exit 1
#     fi

#     # Create the user
#     CREATE_USER="CREATE ROLE $POSTGRESQL_USER WITH
#                 LOGIN               
#                 NOSUPERUSER         
#                 NOCREATEDB          
#                 NOCREATEROLE        
#                 INHERIT             
#                 NOREPLICATION       
#                 NOBYPASSRLS         
#                 CONNECTION LIMIT -1 
#                 PASSWORD '$POSTGRESQL_USER_PASSWORD'; "

#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_USER"

#     # Create the database
#     CREATE_DATABASE="CREATE DATABASE $POSTGRESQL_DATABASE WITH
#                      OWNER = $POSTGRESQL_USER
#                      ENCODING = 'UTF8'
#                      LOCALE_PROVIDER = 'libc'
#                      CONNECTION LIMIT = -1
#                      IS_TEMPLATE = False;"
#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_DATABASE"

#     # Grant permissions to the user on the database
#     GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
#                   COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$GRANT_SCRIPT"

#     # Comment on the user
#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
#         -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
# done




# #!/bin/bash

# set -e

# IFS=',' read -ra USERS <<< "$USERS"
# IFS=',' read -ra PASSWORDS <<< "$PASSWORDS"
# IFS=',' read -ra DATABASES <<< "$DATABASES"

# for ((i=0; i<${#USERS[@]}; i++)); do
#     POSTGRESQL_USER="${USERS[$i]}"
#     POSTGRESQL_DATABASE="${DATABASES[$i]}"
#     POSTGRESQL_USER_PASSWORD="${PASSWORDS[$i]}"
#     POSTGRESQL_USER_COMMENT="User Comment for $POSTGRESQL_USER"
#     POSTGRESQL_DB_COMMENT="DB Comment for $POSTGRESQL_DATABASE"

#     # Check if the user already exists
#     USER_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_roles WHERE rolname='$POSTGRESQL_USER'")

#     if [ "$USER_EXISTS" != "1" ]; then
#         # Create the user if it doesn't exist
#         CREATE_USER="CREATE ROLE $POSTGRESQL_USER WITH
#                     LOGIN               
#                     NOSUPERUSER         
#                     NOCREATEDB          
#                     NOCREATEROLE        
#                     INHERIT             
#                     NOREPLICATION       
#                     NOBYPASSRLS         
#                     CONNECTION LIMIT -1 
#                     PASSWORD '$POSTGRESQL_USER_PASSWORD'; "
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_USER"
#     else
#         echo "User $POSTGRESQL_USER already exists. Skipping user creation."
#         continue  # Skip to the next iteration of the loop
#     fi

#     # Check if the database exists
#     DB_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_database WHERE datname='$POSTGRESQL_DATABASE'")

#     if [ "$DB_EXISTS" != "1" ]; then
#         # Create the database if it doesn't exist
#         CREATE_DATABASE="CREATE DATABASE $POSTGRESQL_DATABASE WITH
#                          OWNER = $POSTGRESQL_USER
#                          ENCODING = 'UTF8'
#                          LOCALE_PROVIDER = 'libc'
#                          CONNECTION LIMIT = -1
#                          IS_TEMPLATE = False;"
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_DATABASE"
#     else
#         echo "Database $POSTGRESQL_DATABASE already exists. Skipping database creation."
#     fi

#     # Grant permissions to the user on the database
#     GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
#                   COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$GRANT_SCRIPT"

#     # Comment on the user
#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
#         -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
# done





# #!/bin/bash

# set -e

# IFS=',' read -ra USERS <<< "$USERS"
# IFS=',' read -ra PASSWORDS <<< "$PASSWORDS"
# IFS=',' read -ra DATABASES <<< "$DATABASES"

# for ((i=0; i<${#USERS[@]}; i++)); do
#     POSTGRESQL_USER="${USERS[$i]}"
#     POSTGRESQL_DATABASE="${DATABASES[$i]}"
#     POSTGRESQL_USER_PASSWORD="${PASSWORDS[$i]}"
#     POSTGRESQL_USER_COMMENT="User Comment for $POSTGRESQL_USER"
#     POSTGRESQL_DB_COMMENT="DB Comment for $POSTGRESQL_DATABASE"

#     # Check if the user already exists
#     USER_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_roles WHERE rolname='$POSTGRESQL_USER'")

#     if [ "$USER_EXISTS" != "1" ]; then
#         # Create the user if it doesn't exist
#         CREATE_USER="CREATE ROLE $POSTGRESQL_USER WITH
#                     LOGIN               
#                     NOSUPERUSER         
#                     NOCREATEDB          
#                     NOCREATEROLE        
#                     INHERIT             
#                     NOREPLICATION       
#                     NOBYPASSRLS         
#                     CONNECTION LIMIT -1 
#                     PASSWORD '$POSTGRESQL_USER_PASSWORD'; "
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_USER"
#     else
#         echo "User $POSTGRESQL_USER already exists. Skipping user creation."
#     fi

#     # Check if the database exists
#     DB_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_database WHERE datname='$POSTGRESQL_DATABASE'")

#     if [ "$DB_EXISTS" != "1" ]; then
#         # Create the database if it doesn't exist
#         CREATE_DATABASE="CREATE DATABASE $POSTGRESQL_DATABASE WITH
#                          OWNER = $POSTGRESQL_USER
#                          ENCODING = 'UTF8'
#                          LOCALE_PROVIDER = 'libc'
#                          CONNECTION LIMIT = -1
#                          IS_TEMPLATE = False;"
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_DATABASE"
#     else
#         echo "Database $POSTGRESQL_DATABASE already exists. Skipping database creation."
#     fi

#     # Grant permissions to the user on the database
#     GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
#                   COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" <<<"$GRANT_SCRIPT"

#     # Comment on the user
#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
#         -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
# done






# USERS=($USERS)
# DATABASES=($DATABASES)
# PASSWORDS=($PASSWORDS)

# for ((i=0; i<${#USERS[@]}; i++)); do
#     POSTGRESQL_USER="${USERS[$i]}"
#     POSTGRESQL_DATABASE="${DATABASES[$i]}"
#     POSTGRESQL_USER_PASSWORD="${PASSWORDS[$i]}"
#     POSTGRESQL_USER_COMMENT="User Comment for $POSTGRESQL_USER"
#     POSTGRESQL_DB_COMMENT="DB Comment for $POSTGRESQL_DATABASE"
    

#     # Check if the user already exists
#     USER_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_roles WHERE rolname='$POSTGRESQL_USER'")

#     if [ "$USER_EXISTS" != "1" ]; then
#         # Create the user if it doesn't exist
#         # createuser --username "postgres" "$POSTGRESQL_USER"
#         CREATE_USER="CREATE ROLE $POSTGRESQL_USER WITH
#                     LOGIN               
#                     NOSUPERUSER         
#                     NOCREATEDB          
#                     NOCREATEROLE        
#                     INHERIT             
#                     NOREPLICATION       
#                     NOBYPASSRLS         
#                     CONNECTION LIMIT -1 
#                     PASSWORD '$POSTGRESQL_USER_PASSWORD'; "
#       psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_USER"

#         # Check the exit status
#         if [ $? -ne 0 ]; then
#             echo "Error creating user: $POSTGRESQL_USER"
#             exit 1
#         fi

#     fi

#     # Check if the database exists
#     DB_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_database WHERE datname='$POSTGRESQL_DATABASE'")

#     if [ "$DB_EXISTS" != "1" ]; then
#         # Create the database if it doesn't exist
#         # createdb --username "postgres" "$POSTGRESQL_DATABASE"
#         CREATE_DATABASE="CREATE DATABASE $POSTGRESQL_DATABASE WITH
#                          OWNER = $POSTGRESQL_USER
#                          CONNECTION LIMIT = -1
#                          IS_TEMPLATE = False;"    
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" <<<"$CREATE_DATABASE"

#         # Check the exit status
#         if [ $? -ne 0 ]; then
#             echo "Error creating database: $POSTGRESQL_DATABASE"
#             exit 1
#         fi
        
#     fi

#     # Grant permissions to the user on the database
#     GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
#                   COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" <<<"$GRANT_SCRIPT"
    
#     # Comment on the user
#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
#         -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
# done





# #!/bin/bash

# set -e

# IFS=',' read -ra USERS <<< "$USERS"
# IFS=',' read -ra PASSWORDS <<< "$PASSWORDS"
# IFS=',' read -ra DATABASES <<< "$DATABASES"

# # Function to wait for PostgreSQL to start
# wait_for_postgres() {
#     echo "Waiting for PostgreSQL to start..."
#     sleep 10  # Wait for 10 seconds
#     until psql -U "postgres" -c '\q' 2>/dev/null; do
#         echo "Retrying..."
#         pg_isready -d "postgres" -U "postgres" -h "localhost" -p "5432" -t 2
#         sleep 2
#     done
# }


# wait_for_postgres

# for ((i=0; i<${#USERS[@]}; i++)); do
#     POSTGRESQL_USER="${USERS[$i]}"
#     POSTGRESQL_DATABASE="${DATABASES[$i]}"
#     POSTGRESQL_USER_PASSWORD="${PASSWORDS[$i]}"
#     POSTGRESQL_USER_COMMENT="User Comment for $POSTGRESQL_USER"
#     POSTGRESQL_DB_COMMENT="DB Comment for $POSTGRESQL_DATABASE"

#     # Check if the user already exists
#     psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_roles WHERE rolname='$POSTGRESQL_USER'" || {
#         # Create the user if it doesn't exist
#         CREATE_USER="CREATE ROLE $POSTGRESQL_USER WITH
#                     LOGIN               
#                     NOSUPERUSER         
#                     NOCREATEDB          
#                     NOCREATEROLE        
#                     INHERIT             
#                     NOREPLICATION       
#                     NOBYPASSRLS         
#                     CONNECTION LIMIT -1 
#                     PASSWORD '$POSTGRESQL_USER_PASSWORD'; "
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_USER"
#     }

#     # Check if the database exists
#     psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_database WHERE datname='$POSTGRESQL_DATABASE'" || {
#         # Create the database if it doesn't exist
#         CREATE_DATABASE="CREATE DATABASE $POSTGRESQL_DATABASE WITH
#                          OWNER = $POSTGRESQL_USER
#                          ENCODING = 'UTF8'
#                          LOCALE_PROVIDER = 'libc'
#                          CONNECTION LIMIT = -1
#                          IS_TEMPLATE = False;"
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_DATABASE"
#     }

#     # Grant permissions to the user on the database
#     GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
#                   COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" <<<"$GRANT_SCRIPT"

#     # Comment on the user
#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
#         -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
# done




# #!/bin/bash

# set -e

# IFS=',' read -ra USERS <<< "$USERS"
# IFS=',' read -ra PASSWORDS <<< "$PASSWORDS"
# IFS=',' read -ra DATABASES <<< "$DATABASES"

# for ((i=0; i<${#USERS[@]}; i++)); do
#     POSTGRESQL_USER="${USERS[$i]}"
#     POSTGRESQL_DATABASE="${DATABASES[$i]}"
#     POSTGRESQL_USER_PASSWORD="${PASSWORDS[$i]}"
#     POSTGRESQL_USER_COMMENT="User Comment for $POSTGRESQL_USER"
#     POSTGRESQL_DB_COMMENT="DB Comment for $POSTGRESQL_DATABASE"

#     # Check if the user already exists
#     USER_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_roles WHERE rolname='$POSTGRESQL_USER'")

#     if [ "$USER_EXISTS" != "1" ]; then
#         # Create the user if it doesn't exist
#         CREATE_USER="CREATE ROLE $POSTGRESQL_USER WITH
#                     LOGIN               
#                     NOSUPERUSER         
#                     NOCREATEDB          
#                     NOCREATEROLE        
#                     INHERIT             
#                     NOREPLICATION       
#                     NOBYPASSRLS         
#                     CONNECTION LIMIT -1 
#                     PASSWORD '$POSTGRESQL_USER_PASSWORD'; "
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_USER"
#     else
#         echo "User '$POSTGRESQL_USER' already exists. Skipping user creation."
#         exit 0  # Exit script immediately, assuming all tasks are completed
#     fi

#     # Check if the database already exists
#     DB_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_database WHERE datname='$POSTGRESQL_DATABASE'")

#     if [ "$DB_EXISTS" != "1" ]; then
#         # Create the database if it doesn't exist
#         CREATE_DATABASE="CREATE DATABASE $POSTGRESQL_DATABASE WITH
#                          OWNER = $POSTGRESQL_USER
#                          ENCODING = 'UTF8'
#                          LOCALE_PROVIDER = 'libc'
#                          CONNECTION LIMIT = -1
#                          IS_TEMPLATE = False;"    
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_DATABASE"
#     else
#         echo "Database '$POSTGRESQL_DATABASE' already exists. Skipping database creation."
#         exit 0  # Exit script immediately, assuming all tasks are completed
#     fi

#     # Grant permissions to the user on the database
#     GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
#                   COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" <<<"$GRANT_SCRIPT"
    
#     # Comment on the user
#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
#         -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
# done

# # Self-delete the script
# rm -- "$0"




# #!/bin/bash

# set -e

# IFS=',' read -ra USERS <<< "$USERS"
# IFS=',' read -ra PASSWORDS <<< "$PASSWORDS"
# IFS=',' read -ra DATABASES <<< "$DATABASES"

# for ((i=0; i<${#USERS[@]}; i++)); do
#     POSTGRESQL_USER="${USERS[$i]}"
#     POSTGRESQL_DATABASE="${DATABASES[$i]}"
#     POSTGRESQL_USER_PASSWORD="${PASSWORDS[$i]}"
#     POSTGRESQL_USER_COMMENT="User Comment for $POSTGRESQL_USER"
#     POSTGRESQL_DB_COMMENT="DB Comment for $POSTGRESQL_DATABASE"

#     # Check if the user already exists
#     USER_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_roles WHERE rolname='$POSTGRESQL_USER'")

#     # Check if the database already exists
#     DB_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_database WHERE datname='$POSTGRESQL_DATABASE'")

#     if [ "$USER_EXISTS" != "1" ] || [ "$DB_EXISTS" != "1" ]; then
#         # Create the user if it doesn't exist
#         CREATE_USER="CREATE ROLE $POSTGRESQL_USER WITH
#                     LOGIN               
#                     NOSUPERUSER         
#                     NOCREATEDB          
#                     NOCREATEROLE        
#                     INHERIT             
#                     NOREPLICATION       
#                     NOBYPASSRLS         
#                     CONNECTION LIMIT -1 
#                     PASSWORD '$POSTGRESQL_USER_PASSWORD'; "
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_USER"

#         # Create the database if it doesn't exist
#         CREATE_DATABASE="CREATE DATABASE $POSTGRESQL_DATABASE WITH
#                          OWNER = $POSTGRESQL_USER
#                          ENCODING = 'UTF8'
#                          LOCALE_PROVIDER = 'libc'
#                          CONNECTION LIMIT = -1
#                          IS_TEMPLATE = False;"    
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_DATABASE"

#         # Grant permissions to the user on the database
#         GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
#                       COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" <<<"$GRANT_SCRIPT"
        
#         # Comment on the user
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
#             -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
#     else
#         echo "User '$POSTGRESQL_USER' and Database '$POSTGRESQL_DATABASE' already exist. Skipping user and database creation."
        
#         # Self-delete the script since the conditions are met
#         rm -- "$0"
#     fi
# done





# #!/bin/bash

# set -e

# IFS=',' read -ra USERS <<< "$USERS"
# IFS=',' read -ra PASSWORDS <<< "$PASSWORDS"
# IFS=',' read -ra DATABASES <<< "$DATABASES"

# for ((i=0; i<${#USERS[@]}; i++)); do
#     POSTGRESQL_USER="${USERS[$i]}"
#     POSTGRESQL_DATABASE="${DATABASES[$i]}"
#     POSTGRESQL_USER_PASSWORD="${PASSWORDS[$i]}"
#     POSTGRESQL_USER_COMMENT="User Comment for $POSTGRESQL_USER"
#     POSTGRESQL_DB_COMMENT="DB Comment for $POSTGRESQL_DATABASE"

#     # Check if the user already exists
#     USER_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_roles WHERE rolname='$POSTGRESQL_USER'")

#     if [ "$USER_EXISTS" != "1" ]; then
#         # Create the user if it doesn't exist
#         CREATE_USER="CREATE ROLE $POSTGRESQL_USER WITH
#                     LOGIN               
#                     NOSUPERUSER         
#                     NOCREATEDB          
#                     NOCREATEROLE        
#                     INHERIT             
#                     NOREPLICATION       
#                     NOBYPASSRLS         
#                     CONNECTION LIMIT -1 
#                     PASSWORD '$POSTGRESQL_USER_PASSWORD'; "
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_USER"
#     else
#         echo "User '$POSTGRESQL_USER' already exists. Skipping user creation."
#     fi

#     # Check if the database already exists
#     DB_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_database WHERE datname='$POSTGRESQL_DATABASE'")

#     if [ "$DB_EXISTS" != "1" ]; then
#         # Create the database if it doesn't exist
#         CREATE_DATABASE="CREATE DATABASE $POSTGRESQL_DATABASE WITH
#                          OWNER = $POSTGRESQL_USER
#                          ENCODING = 'UTF8'
#                          LOCALE_PROVIDER = 'libc'
#                          CONNECTION LIMIT = -1
#                          IS_TEMPLATE = False;"    
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_DATABASE"
#     else
#         echo "Database '$POSTGRESQL_DATABASE' already exists. Skipping database creation."
#     fi

#     # Grant permissions to the user on the database
#     GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
#                   COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" <<<"$GRANT_SCRIPT"
    
#     # Comment on the user
#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
#         -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
# done

# rm -- "$0"


# #!/bin/bash

# set -e

# IFS=',' read -ra USERS <<< "$USERS"
# IFS=',' read -ra PASSWORDS <<< "$PASSWORDS"
# IFS=',' read -ra DATABASES <<< "$DATABASES"

# for ((i=0; i<${#USERS[@]}; i++)); do
#     POSTGRESQL_USER="${USERS[$i]}"
#     POSTGRESQL_DATABASE="${DATABASES[$i]}"
#     POSTGRESQL_USER_PASSWORD="${PASSWORDS[$i]}"
#     POSTGRESQL_USER_COMMENT="User Comment for $POSTGRESQL_USER"
#     POSTGRESQL_DB_COMMENT="DB Comment for $POSTGRESQL_DATABASE"

#     # Check if the user already exists
#     USER_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_roles WHERE rolname='$POSTGRESQL_USER'")

#     if [ "$USER_EXISTS" != "1" ]; then
#         # Create the user if it doesn't exist
#         CREATE_USER="CREATE ROLE $POSTGRESQL_USER WITH
#                     LOGIN               
#                     NOSUPERUSER         
#                     NOCREATEDB          
#                     NOCREATEROLE        
#                     INHERIT             
#                     NOREPLICATION       
#                     NOBYPASSRLS         
#                     CONNECTION LIMIT -1 
#                     PASSWORD '$POSTGRESQL_USER_PASSWORD'; "
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_USER"
#     else
#         echo "User '$POSTGRESQL_USER' already exists. Skipping user creation."
#     fi

#     # Check if the database exists
#     DB_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_database WHERE datname='$POSTGRESQL_DATABASE'")

#     if [ "$DB_EXISTS" != "1" ]; then
#         # Create the database if it doesn't exist
#         CREATE_DATABASE="CREATE DATABASE $POSTGRESQL_DATABASE WITH
#                          OWNER = $POSTGRESQL_USER
#                          ENCODING = 'UTF8'
#                          LOCALE_PROVIDER = 'libc'
#                          CONNECTION LIMIT = -1
#                          IS_TEMPLATE = False;"    
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_DATABASE"
#     else
#         echo "Database '$POSTGRESQL_DATABASE' already exists. Skipping database creation."
#     fi

#     # Grant permissions to the user on the database
#     GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
#                   COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" <<<"$GRANT_SCRIPT"
    
#     # Comment on the user
#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
#         -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
# done




# working
# #!/bin/bash

# set -e

# IFS=',' read -ra USERS <<< "$USERS"
# IFS=',' read -ra PASSWORDS <<< "$PASSWORDS"
# IFS=',' read -ra DATABASES <<< "$DATABASES"


# for ((i=0; i<${#USERS[@]}; i++)); do
#     POSTGRESQL_USER="${USERS[$i]}"
#     POSTGRESQL_DATABASE="${DATABASES[$i]}"
#     POSTGRESQL_USER_PASSWORD="${PASSWORDS[$i]}"
#     POSTGRESQL_USER_COMMENT="User Comment for $POSTGRESQL_USER"
#     POSTGRESQL_DB_COMMENT="DB Comment for $POSTGRESQL_DATABASE"
    

#     # Check if the user already exists
#     USER_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_roles WHERE rolname='$POSTGRESQL_USER'")

#     if [ "$USER_EXISTS" != "1" ]; then
#         # Create the user if it doesn't exist
#         CREATE_USER="CREATE ROLE $POSTGRESQL_USER WITH
#                     LOGIN               
#                     NOSUPERUSER         
#                     NOCREATEDB          
#                     NOCREATEROLE        
#                     INHERIT             
#                     NOREPLICATION       
#                     NOBYPASSRLS         
#                     CONNECTION LIMIT -1 
#                     PASSWORD '$POSTGRESQL_USER_PASSWORD'; "
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_USER"
#     fi

#     # Check if the database exists
#     DB_EXISTS=$(psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_database WHERE datname='$POSTGRESQL_DATABASE'")

#     if [ "$DB_EXISTS" != "1" ]; then
#         # Create the database if it doesn't exist
#         CREATE_DATABASE="CREATE DATABASE $POSTGRESQL_DATABASE WITH
#                          OWNER = $POSTGRESQL_USER
#                          ENCODING = 'UTF8'
#                          LOCALE_PROVIDER = 'libc'
#                          CONNECTION LIMIT = -1
#                          IS_TEMPLATE = False;"    
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_DATABASE"
#     fi

#     # Grant permissions to the user on the database
#     GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
#                   COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" <<<"$GRANT_SCRIPT"
    
#     # Comment on the user
#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
#         -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
# done


# #!/bin/bash

# set -e

# IFS=',' read -ra USERS <<< "$USERS"
# IFS=',' read -ra PASSWORDS <<< "$PASSWORDS"
# IFS=',' read -ra DATABASES <<< "$DATABASES"

# for ((i=0; i<${#USERS[@]}; i++)); do
#     POSTGRESQL_USER="${USERS[$i]}"
#     POSTGRESQL_DATABASE="${DATABASES[$i]}"
#     POSTGRESQL_USER_PASSWORD="${PASSWORDS[$i]}"
#     POSTGRESQL_USER_COMMENT="User Comment for $POSTGRESQL_USER"
#     POSTGRESQL_DB_COMMENT="DB Comment for $POSTGRESQL_DATABASE"

#     # Check if the user already exists
#     psql --username "postgres" --dbname "postgres" -t -c "SELECT 1 FROM pg_roles WHERE rolname='$POSTGRESQL_USER'" || {
#         # Create the user if it doesn't exist
#         CREATE_USER="CREATE ROLE $POSTGRESQL_USER WITH
#                     LOGIN               
#                     NOSUPERUSER         
#                     NOCREATEDB          
#                     NOCREATEROLE        
#                     INHERIT             
#                     NOREPLICATION       
#                     NOBYPASSRLS         
#                     CONNECTION LIMIT -1 
#                     PASSWORD '$POSTGRESQL_USER_PASSWORD'; "
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_USER"
#     }

#     # Check if the database exists
#     psql --username "postgres" --dbname "postgres" -t -c "SELECT 1 FROM pg_database WHERE datname='$POSTGRESQL_DATABASE'" || {
#         # Create the database if it doesn't exist
#         CREATE_DATABASE="CREATE DATABASE $POSTGRESQL_DATABASE WITH
#                          OWNER = $POSTGRESQL_USER
#                          ENCODING = 'UTF8'
#                          LOCALE_PROVIDER = 'libc'
#                          CONNECTION LIMIT = -1
#                          IS_TEMPLATE = False;"
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_DATABASE"
#     }

#     # Grant permissions to the user on the database
#     GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
#                   COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" <<<"$GRANT_SCRIPT"

#     # Comment on the user
#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
#         -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
# done


# #!/bin/bash

# set -e

# IFS=',' read -ra USERS <<< "$USERS"
# IFS=',' read -ra PASSWORDS <<< "$PASSWORDS"
# IFS=',' read -ra DATABASES <<< "$DATABASES"

# # Function to wait for PostgreSQL to start
# wait_for_postgres() {
#     until psql -U "postgres" -c '\q' 2>/dev/null; do
#         echo "Waiting for PostgreSQL to start..."
#         sleep 2
#     done
# }

# wait_for_postgres

# # Connect to the default 'postgres' database
# psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<-EOSQL
#     DO \$\$
#     BEGIN
#         FOR i IN 1..${#USERS[@]} LOOP
#             DECLARE
#                 user_exists integer;
#                 db_exists integer;
#             BEGIN
#                 EXECUTE 'SELECT 1 FROM pg_roles WHERE rolname=''${USERS[i]}''' INTO user_exists;
                
#                 IF user_exists IS NULL THEN
#                     EXECUTE 'CREATE ROLE ${USERS[i]} WITH
#                         LOGIN               
#                         NOSUPERUSER         
#                         NOCREATEDB          
#                         NOCREATEROLE        
#                         INHERIT             
#                         NOREPLICATION       
#                         NOBYPASSRLS         
#                         CONNECTION LIMIT -1 
#                         PASSWORD ''${PASSWORDS[i]}''';
#                 END IF;

#                 EXECUTE 'SELECT 1 FROM pg_database WHERE datname=''${DATABASES[i]}''' INTO db_exists;

#                 IF db_exists IS NULL THEN
#                     EXECUTE 'CREATE DATABASE ${DATABASES[i]} WITH
#                         OWNER = ${USERS[i]}
#                         ENCODING = ''UTF8''
#                         LOCALE_PROVIDER = ''libc''
#                         CONNECTION LIMIT = -1
#                         IS_TEMPLATE = False;';
#                 END IF;
#             END;
#         END LOOP;
#     END
#     \$\$;
# EOSQL

# # Grant permissions and add comments (outside the loop for simplicity)
# for ((i=0; i<${#USERS[@]}; i++)); do
#     POSTGRESQL_USER="${USERS[$i]}"
#     POSTGRESQL_DATABASE="${DATABASES[$i]}"
#     POSTGRESQL_USER_COMMENT="User Comment for $POSTGRESQL_USER"
#     POSTGRESQL_DB_COMMENT="DB Comment for $POSTGRESQL_DATABASE"

#     GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
#                   COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" <<<"$GRANT_SCRIPT"
    
#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
#         -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
# done







# #!/bin/bash

# set -e

# IFS=',' read -ra USERS <<< "$USERS"
# IFS=',' read -ra PASSWORDS <<< "$PASSWORDS"
# IFS=',' read -ra DATABASES <<< "$DATABASES"

# # Function to wait for PostgreSQL to start
# wait_for_postgres() {
#     until psql -U "postgres" -c '\q' 2>/dev/null; do
#         echo "Waiting for PostgreSQL to start..."
#         sleep 2
#     done
# }

# wait_for_postgres

# # Connect to the default 'postgres' database
# psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<-EOSQL
#     -- Loop through each user and database
#     DO \$\$
#     BEGIN
#         FOR i IN 1..${#USERS[@]} LOOP
#             DECLARE
#                 user_exists integer;
#                 db_exists integer;
#             BEGIN
#                 -- Check if the user already exists
#                 SELECT 1 INTO user_exists FROM pg_roles WHERE rolname='${USERS[i]}';
                
#                 IF user_exists IS NULL THEN
#                     -- Create the user if it doesn't exist
#                     EXECUTE 'CREATE ROLE ${USERS[i]} WITH
#                         LOGIN               
#                         NOSUPERUSER         
#                         NOCREATEDB          
#                         NOCREATEROLE        
#                         INHERIT             
#                         NOREPLICATION       
#                         NOBYPASSRLS         
#                         CONNECTION LIMIT -1 
#                         PASSWORD ''${PASSWORDS[i]}'';';
#                 END IF;

#                 -- Check if the database already exists
#                 SELECT 1 INTO db_exists FROM pg_database WHERE datname='${DATABASES[i]}';

#                 IF db_exists IS NULL THEN
#                     -- Create the database if it doesn't exist
#                     EXECUTE 'CREATE DATABASE ${DATABASES[i]} WITH
#                         OWNER = ${USERS[i]}
#                         ENCODING = ''UTF8''
#                         LOCALE_PROVIDER = ''libc''
#                         CONNECTION LIMIT = -1
#                         IS_TEMPLATE = False;';
#                 END IF;
#             END;
#         END LOOP;
#     END
#     \$\$;
# EOSQL

# # Grant permissions and add comments (outside the loop for simplicity)
# for ((i=0; i<${#USERS[@]}; i++)); do
#     POSTGRESQL_USER="${USERS[$i]}"
#     POSTGRESQL_DATABASE="${DATABASES[$i]}"
#     POSTGRESQL_USER_COMMENT="User Comment for $POSTGRESQL_USER"
#     POSTGRESQL_DB_COMMENT="DB Comment for $POSTGRESQL_DATABASE"

#     # Grant permissions to the user on the database
#     GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
#                   COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" <<<"$GRANT_SCRIPT"
    
#     # Comment on the user
#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
#         -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
# done




# #!/bin/bash

# set -e

# IFS=',' read -ra USERS <<< "$USERS"
# IFS=',' read -ra PASSWORDS <<< "$PASSWORDS"
# IFS=',' read -ra DATABASES <<< "$DATABASES"

# # Function to wait for PostgreSQL to start
# wait_for_postgres() {
#     until psql -U "postgres" -c '\q' 2>/dev/null; do
#         echo "Waiting for PostgreSQL to start..."
#         sleep 2
#     done
# }

# wait_for_postgres

# for ((i=0; i<${#USERS[@]}; i++)); do
#     POSTGRESQL_USER="${USERS[$i]}"
#     POSTGRESQL_DATABASE="${DATABASES[$i]}"
#     POSTGRESQL_USER_PASSWORD="${PASSWORDS[$i]}"
#     POSTGRESQL_USER_COMMENT="User Comment for $POSTGRESQL_USER"
#     POSTGRESQL_DB_COMMENT="DB Comment for $POSTGRESQL_DATABASE"

#     # Check if the user already exists
#     psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_roles WHERE rolname='$POSTGRESQL_USER'" || {
#         # Create the user if it doesn't exist
#         CREATE_USER="CREATE ROLE $POSTGRESQL_USER WITH
#                     LOGIN               
#                     NOSUPERUSER         
#                     NOCREATEDB          
#                     NOCREATEROLE        
#                     INHERIT             
#                     NOREPLICATION       
#                     NOBYPASSRLS         
#                     CONNECTION LIMIT -1 
#                     PASSWORD '$POSTGRESQL_USER_PASSWORD'; "
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_USER"
#     }

#     # Check if the database exists
#     psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_database WHERE datname='$POSTGRESQL_DATABASE'" || {
#         # Create the database if it doesn't exist
#         CREATE_DATABASE="CREATE DATABASE $POSTGRESQL_DATABASE WITH
#                          OWNER = $POSTGRESQL_USER
#                          ENCODING = 'UTF8'
#                          LOCALE_PROVIDER = 'libc'
#                          CONNECTION LIMIT = -1
#                          IS_TEMPLATE = False;"
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_DATABASE"
#     }

#     # Grant permissions to the user on the database
#     GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
#                   COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" <<<"$GRANT_SCRIPT"

#     # Comment on the user
#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
#         -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
# done




# #!/bin/bash

# set -e

# IFS=',' read -ra USERS <<< "$USERS"
# IFS=',' read -ra PASSWORDS <<< "$PASSWORDS"
# IFS=',' read -ra DATABASES <<< "$DATABASES"

# for ((i=0; i<${#USERS[@]}; i++)); do
#     POSTGRESQL_USER="${USERS[$i]}"
#     POSTGRESQL_DATABASE="${DATABASES[$i]}"
#     POSTGRESQL_USER_PASSWORD="${PASSWORDS[$i]}"
#     POSTGRESQL_USER_COMMENT="User Comment for $POSTGRESQL_USER"
#     POSTGRESQL_DB_COMMENT="DB Comment for $POSTGRESQL_DATABASE"

#     # Check if the user already exists
#     psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_roles WHERE rolname='$POSTGRESQL_USER'" || {
#         # Create the user if it doesn't exist
#         CREATE_USER="CREATE ROLE $POSTGRESQL_USER WITH
#                     LOGIN               
#                     NOSUPERUSER         
#                     NOCREATEDB          
#                     NOCREATEROLE        
#                     INHERIT             
#                     NOREPLICATION       
#                     NOBYPASSRLS         
#                     CONNECTION LIMIT -1 
#                     PASSWORD '$POSTGRESQL_USER_PASSWORD'; "
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_USER"
#     }

#     # Check if the database exists
#     psql -t --username "postgres" --dbname "postgres" -c "SELECT 1 FROM pg_database WHERE datname='$POSTGRESQL_DATABASE'" || {
#         # Create the database if it doesn't exist
#         CREATE_DATABASE="CREATE DATABASE $POSTGRESQL_DATABASE WITH
#                          OWNER = $POSTGRESQL_USER
#                          ENCODING = 'UTF8'
#                          LOCALE_PROVIDER = 'libc'
#                          CONNECTION LIMIT = -1
#                          IS_TEMPLATE = False;"
#         psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "postgres" <<<"$CREATE_DATABASE"
#     }

#     # Grant permissions to the user on the database
#     GRANT_SCRIPT="GRANT ALL ON DATABASE $POSTGRESQL_DATABASE TO $POSTGRESQL_USER WITH GRANT OPTION; \
#                   COMMENT ON DATABASE $POSTGRESQL_DATABASE IS '$POSTGRESQL_DATABASE - $POSTGRESQL_DB_COMMENT';"

#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" <<<"$GRANT_SCRIPT"

#     # Comment on the user
#     psql -v ON_ERROR_STOP=1 --username "postgres" --dbname "$POSTGRESQL_DATABASE" \
#         -c "COMMENT ON ROLE $POSTGRESQL_USER IS '$POSTGRESQL_USER_COMMENT';"
# done