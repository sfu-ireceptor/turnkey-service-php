#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec -T ireceptor-database \
	sh -c 'mongo --quiet /app/scripts/drop_indexes.js && \
			echo && \
			echo "Restoring database..." \
			mongorestore --noIndexRestore --archive && \
			echo "Done" \
			echo && \
			cd /app && mongo --quiet /app/scripts/create_indexes.js && \
			cd /app && mongo --quiet /app/scripts/create_query_plans.js && \
			echo && \
			echo "Your database was sucessfully restored."'
