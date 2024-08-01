#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

sudo docker compose -f ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec ireceptor-database sh -c 'mongo $MONGO_INITDB_DATABASE'
