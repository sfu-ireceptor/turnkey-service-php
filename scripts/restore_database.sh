#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# check number of arguments
NB_ARGS=1
if [ $# -ne $NB_ARGS ];
then
    echo "$0: wrong number of arguments ($# instead of $NB_ARGS)"
    echo "usage: $0 <database dump>"
    exit 1
fi

DATABASE_DUMP="$1"

sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec -T ireceptor-database \
	sh -c 'mongorestore --archive' < $DATABASE_DUMP


