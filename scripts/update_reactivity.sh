#!/bin/bash

SCRIPT_DIR=`dirname "$0"`
SCRIPT_FILE_NAME=`basename "$0"`

# check number of arguments
if [[ $# -gt 3 || $# -lt 1 ]];
then
    echo "$0: wrong number of arguments ($#)"
    echo "usage: $0 sequence_file [--skipload] [--append]"
    exit 1
fi

SEQUENCE_FILE=$1
SKIPLOAD=""
APPEND=""
if [[ "$2" = "--skipload" || "$3" = "--skipload" ]];
then
    SKIPLOAD="--skipload"
    echo "Note: Using --skipload, no database changes will be made."
fi
if [[ "$2" = "--append" || "$3" = "--append" ]];
then
    APPEND="--append"
fi

FILE_ABSOLUTE_PATH=`realpath "$SEQUENCE_FILE"`
FILE_FOLDER=`dirname "$FILE_ABSOLUTE_PATH"`
FILE_NAME=`basename "$FILE_ABSOLUTE_PATH"`

# create log file
LOG_FOLDER=${SCRIPT_DIR}/../log
mkdir -p $LOG_FOLDER
TIME1=`date +%Y-%m-%d_%H-%M-%S`
LOG_FILE=${LOG_FOLDER}/${TIME1}_${SCRIPT_FILE_NAME}.log

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
				-e SKIPLOAD="$SKIPLOAD" \
				-e APPEND="$APPEND" \
				-e SEQUENCE_FILE="$SEQUENCE_FILE" \
			ireceptor-dataloading  \
				sh -c 'python /app/dataload/add_reactivity.py \
				        --mapfile=/app/config/AIRR-iReceptorMapping.txt \
                                        --host=$DB_HOST \
                                        --database=$DB_DATABASE \
                                        --repertoire_collection sample \
                                        --rearrangement_collection sequence \
					--verbose \
					--reactivity_method "IEDB:EXACT:v_gene,j_gene,junction_aa"\
					$SKIPLOAD $APPEND\
					/scratch/$FILE_NAME \
					'\
 	2>&1  | tee $LOG_FILE

if [ $# -eq 2 ];
then
    echo "Note: Upload used $SKIPLOAD, no database changes were made."
fi

TIME2=`date +%Y-%m-%d_%H-%M-%S`
echo "Finished at: $TIME2"

