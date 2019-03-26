#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# create query plans
sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec ireceptor-database \
		sh -c 'cd /app && mongo --quiet $MONGO_INITDB_DATABASE /app/scripts/create_query_plans.js'
