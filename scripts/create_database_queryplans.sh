#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# create query plans
sudo docker compose -f ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec -T ireceptor-database \
		sh -c 'cd /app && mongo --quiet $MONGO_INITDB_DATABASE /app/scripts/create_query_plans.js'
