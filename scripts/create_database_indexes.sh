#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# create indexes
sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec -T ireceptor-database \
		sh -c 'cd /app && mongo --quiet $MONGO_INITDB_DATABASE /app/scripts/create_indexes.js'

# create query plans
${SCRIPT_DIR}/create_database_queryplans.sh
