#!/bin/sh

# Adaptei a idéia do murder - 
# https://gist.github.com/murder/bf5c59291e4e9fd5e06adc9ce71340fc

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Create the 'template_postgis' template db
"${psql[@]}" <<- 'EOSQL'
CREATE DATABASE template_postgis IS_TEMPLATE true;
EOSQL

# Load PostGIS into both template_database and $POSTGRES_DB
for DB in template_postgis "$POSTGRES_DB"; do
        echo "Loading PostGIS extensions into $DB"
        "${psql[@]}" --dbname="$DB" <<-'EOSQL'
                CREATE EXTENSION IF NOT EXISTS postgis;
                CREATE EXTENSION IF NOT EXISTS postgis_topology;
                CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
                CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
                CREATE EXTENSION IF NOT EXISTS pgcrypto;

EOSQL
done
