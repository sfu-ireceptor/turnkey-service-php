#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

echo -n "Starting $0: "
date

# create indexes
sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec -T ireceptor-database \
		sh -c 'cd /app && mongo --quiet $MONGO_INITDB_DATABASE /app/scripts/create_expression_indexes.js'

# create query plans
${SCRIPT_DIR}/create_database_queryplans.sh

echo -n "Done $0: "
date
