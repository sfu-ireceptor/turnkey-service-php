#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec -T ireceptor-database \
	sh -c 'mongo --quiet /app/scripts/drop_rearrangement_indexes.js && \
			mongo --quiet /app/scripts/drop_rearrangement_indexes.js && \
			mongo --quiet /app/scripts/drop_clone_indexes.js && \
			mongo --quiet /app/scripts/drop_cell_indexes.js && \
			mongo --quiet /app/scripts/drop_expression_indexes.js && \
			echo && \
			echo "Restoring database..." && \
			mongorestore --noIndexRestore --archive && \
			echo "Done" && \
			echo && \
			mongo --quiet /app/scripts/create_rearrangement_indexes.js && \
			mongo --quiet /app/scripts/create_clone_indexes.js && \
			mongo --quiet /app/scripts/create_cell_indexes.js && \
			mongo --quiet /app/scripts/create_expression_indexes.js && \
			mongo --quiet /app/scripts/create_query_plans.js && \
			echo && \
			echo "Your database was sucessfully restored."'
