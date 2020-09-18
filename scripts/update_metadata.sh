#!/bin/bash

SCRIPT_DIR=`dirname "$0"`

# check number of arguments
if [[ $# -ne 2 && $# -ne 3 ]];
then
    echo "$0: wrong number of arguments ($#)"
    echo "usage: $0 (ireceptor|repertoire) [--skipload] <metadata_file.csv>"
    exit 1
fi

REPERTOIRE_TYPE="$1"

SKIPLOAD=""
FULLFILE=$2
if [ $# -eq 3 ];
then
    SKIPLOAD=$2
    FULLFILE=$3
    echo "Note: Using $SKIPLOAD, no database changes will be made."
fi

FILE_ABSOLUTE_PATH=`realpath "$FULLFILE"`
FILE_FOLDER=`dirname "$FILE_ABSOLUTE_PATH"`
FILE_NAME=`basename "$FILE_ABSOLUTE_PATH"`

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
			-e FILE_NAME="$FILE_NAME" \
			-e FILE_FOLDER="$FILE_FOLDER" \
			-e REPERTOIRE_TYPE="$REPERTOIRE_TYPE" \
			-e SKIPLOAD="$SKIPLOAD" \
			ireceptor-dataloading  \
				sh -c 'python /app/dataload/dataloader.py -v \
					--mapfile=/app/config/AIRR-iReceptorMapping.txt \
					--host=$DB_HOST \
					--database=$DB_DATABASE \
					--repertoire_collection sample \
					--$REPERTOIRE_TYPE \
                                        --update $SKIPLOAD \
                                        -v \
					-f /scratch/$FILE_NAME' \
 	2>&1 | tee $LOG_FILE


if [ $# -eq 3 ];
then
    echo "Note: Upload used $SKIPLOAD, no database changes were made."
fi
