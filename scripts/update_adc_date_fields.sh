#!/bin/bash
#script that populates adc_publish_date and adc_update_date database fields using 
#  values in ir_created_at and ir_updated_at
SCRIPT_DIR=`dirname "$0"`

# check number of arguments
if [[ $# -ne 0 && $# -ne 1 ]];
then
    echo "$0: wrong number of arguments ($#)"
    echo "usage: $0 <optional check|verbose|check-verbose parameter>"
    echo "check: don't do a database update, return 0 if no updates are needed, 1 otherwise, minimal output"
    echo "verbose: do a database update, return 0 if no issues, 1 otherwise, provide detailed output"
    echo "check-verbose: as check, but with detailed output"
    echo "if no parameter, database will be updated with minimal output"
    exit 1
fi

NO_UPDATE=""

if [ $# -eq 1 ];
then
	NO_UPDATE="$1"
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
				-e COLLECTION_NAME="sample"\
				-e NO_UPDATE="$NO_UPDATE" \
			ireceptor-dataloading  \
				sh -c 'python /app/dataload/update_adc_date_fields.py \
					$DB_HOST \
					$DB_DATABASE \
					$COLLECTION_NAME \
					$NO_UPDATE '\
 	2>&1 | tee $LOG_FILE
