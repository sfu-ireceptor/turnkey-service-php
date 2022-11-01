#!/bin/sh

SCRIPT_DIR=`dirname "$0"`
sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec -T ireceptor-database \
		sh -c 'cd /app && mongo --quiet $MONGO_INITDB_DATABASE /app/scripts/drop_cell_indexes_dataloading.js'
