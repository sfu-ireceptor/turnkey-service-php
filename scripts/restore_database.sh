#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

${SCRIPT_DIR}/drop_database_indexes.sh

sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec -T ireceptor-database \
	sh -c 'mongorestore --noIndexRestore --archive'

${SCRIPT_DIR}/create_database_indexes.sh
