#!/bin/bash

SCRIPT_DIR=`dirname "$0"`

# check number of arguments
if [[ $# -ne 1 && $# -ne 2 ]];
then
    echo "$0: wrong number of arguments ($#)"
    echo "usage: $0 <collection_time_point_relative_field_name>  \
     <optional check|verbose|check-verbose parameter>"
    echo "check: don't do a database update, return 0 if no updates are needed, 1 otherwise, minimal output"
    echo "verbose: do a database update, return 0 if no issues, 1 otherwise, provide detailed output"
    echo "check-verbose: as check, but with detailed output"
    echo "if no parameter, database will be updated with minimal output"
    exit 1
fi

TIMEPOINT_RELATIVE_NAME="$1"
UPDATED_AT_NAME="ir_updated_at"
NO_UPDATE=""

if [ $# -eq 2 ];
then
	NO_UPDATE="$2"
fi

# create log file
LOG_FOLDER=${SCRIPT_DIR}/../log
mkdir -p $LOG_FOLDER
TIME1=`date +%Y-%m-%d_%H-%M-%S`
LOG_FILE=${LOG_FOLDER}/${TIME1}_${FILE_NAME}.log

# make available to docker-compose.yml
export FILE_FOLDER

# Notes:
# sudo -E: make environment variables available to the command run as root
# docker-compose --rm: delete container afterwards 
# docker-compose -e: these variables will be available inside the container
# (but not accessible in docker-compose.yml)
# "ireceptor-dataloading" is the service name defined in docker-compose.yml 
# sh -c '...' is the command executed inside the container
# $DB_HOST and $DB_DATABASE are defined in docker-compose.yml and will be
# substituted only when the python command is executed, INSIDE the container
sudo -E docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service run --rm \
				-e TIMEPOINT_RELATIVE_NAME="$TIMEPOINT_RELATIVE_NAME" \
				-e COLLECTION_NAME="sample"\
				-e UPDATED_AT_NAME="$UPDATED_AT_NAME" \
				-e NO_UPDATE="$NO_UPDATE" \
			ireceptor-dataloading  \
				sh -c 'python /app/dataload/update_collection_timepoint_relative.py \
					$DB_HOST \
					$DB_DATABASE \
					$COLLECTION_NAME \
					$TIMEPOINT_RELATIVE_NAME \
					$UPDATED_AT_NAME \
					$NO_UPDATE '\
 	2>&1 | tee $LOG_FILE