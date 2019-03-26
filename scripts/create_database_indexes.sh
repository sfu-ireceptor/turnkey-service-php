#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# create indexes
sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec ireceptor-database \
		sh -c 'cd /app && mongo --quiet $MONGO_INITDB_DATABASE /app/scripts/create_indexes.js'

# Create the query plans as well...
${SCRIPT_DIR}/create_database_queryplans.sh
