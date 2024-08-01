#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

sudo docker compose -f ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec -T ireceptor-database \
	sh -c 'mongodump --archive'
