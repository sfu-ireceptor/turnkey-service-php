#!/bin/bash

SCRIPT_DIR=`dirname "$0"`
SCRIPT_FILE_NAME=`basename "$0"`

# check number of arguments
if [[ $# -ne 3 && $# -ne 4 ]];
then
    echo "$0: wrong number of arguments ($#)"
    echo "usage: $0 <keywords_study_field_name> <single_cell_field_name> <sequence_count_field_name> \
       <optional check|verbose|check-verbose parameter>"
    echo "check: don't do a database update, return 0 if no updates are needed, 1 otherwise, minimal output"
    echo "verbose: do a database update, return 0 if no issues, 1 otherwise, provide detailed output"
    echo "check-verbose: as check, but with detailed output"
    echo "if no parameter, database will be updated with minimal output"
    exit 1
fi

KEYWORDS_STUDY_FIELD_NAME="$1"
SINGLE_CELL_FIELD_NAME="$2"
SEQUENCE_COUNT_FIELD_NAME="$3"
UPDATED_AT_NAME="ir_updated_at"
NO_UPDATE=""
ERROR_OUTPUT=/dev/stdout

if [ $# -eq 4 ];
then
	NO_UPDATE="$4"
	if [ $NO_UPDATE = "check" ]; then
		ERROR_OUTPUT=/dev/null
	fi
fi

# create log file
LOG_FOLDER=${SCRIPT_DIR}/../log
mkdir -p $LOG_FOLDER
TIME1=`date +%Y-%m-%d_%H-%M-%S`
LOG_FILE=${LOG_FOLDER}/${TIME1}_${SCRIPT_FILE_NAME}.log

# make available to docker-compose.yml
export FILE_FOLDER

# Notes:
# sudo -E: make environment variables available to the command run as root
# docker compose --rm: delete container afterwards 
# docker compose -e: these variables will be available inside the container
# (but not accessible in docker-compose.yml)
# "ireceptor-dataloading" is the service name defined in docker-compose.yml 
# sh -c '...' is the command executed inside the container
# $DB_HOST and $DB_DATABASE are defined in docker-compose.yml and will be
# substituted only when the python command is executed, INSIDE the container
sudo -E docker compose -f ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service run --rm \
				-e KEYWORDS_STUDY_FIELD_NAME="$KEYWORDS_STUDY_FIELD_NAME" \
				-e COLLECTION_NAME="sample"\
				-e SINGLE_CELL_FIELD_NAME="$SINGLE_CELL_FIELD_NAME" \
				-e SEQUENCE_COUNT_FIELD_NAME="$SEQUENCE_COUNT_FIELD_NAME" \
				-e UPDATED_AT_NAME="$UPDATED_AT_NAME" \
				-e NO_UPDATE="$NO_UPDATE" \
			ireceptor-dataloading  \
				sh -c 'python /app/dataload/update_keywords_study.py \
					$DB_HOST \
					$DB_DATABASE \
					$COLLECTION_NAME \
					$KEYWORDS_STUDY_FIELD_NAME \
					$SINGLE_CELL_FIELD_NAME \
					$SEQUENCE_COUNT_FIELD_NAME \
					$UPDATED_AT_NAME \
					$NO_UPDATE '\
 	2> $ERROR_OUTPUT | tee $LOG_FILE
