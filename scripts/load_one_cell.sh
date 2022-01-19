#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

CELL_TYPE="$1"

FILE_ABSOLUTE_PATH=`realpath "$2"`
FILE_FOLDER=`dirname "$FILE_ABSOLUTE_PATH"`
FILE_NAME=`basename "$FILE_ABSOLUTE_PATH"`

# make available to docker-compose.yml
export FILE_FOLDER

# create log file
LOG_FOLDER=${SCRIPT_DIR}/../log
mkdir -p $LOG_FOLDER
TIME1=`date +%Y-%m-%d_%H-%M-%S`
LOG_FILE=${LOG_FOLDER}/${TIME1}_${FILE_NAME}.log

echo "Loading file $2"
echo "Starting at: $TIME1"

# Notes:
# sudo -E: make current environment variables available to the command run as root
# docker-compose --rm: delete container afterwards 
# docker-compose -e: these variables will be available inside the container (but not accessible in docker-compose.yml)
# "ireceptor-dataloading" is the service name defined in docker-compose.yml 
# sh -c '...' is the command executed inside the container
# $DB_HOST and $DB_DATABASE are defined in docker-compose.yml and will be substituted only when the python command is executed, INSIDE the container
sudo -E docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service run --rm \
			-e FILE_NAME="$FILE_NAME" \
			-e FILE_FOLDER="$FILE_FOLDER" \
			-e CELL_TYPE="$CELL_TYPE" \
			ireceptor-dataloading \
				sh -c 'python /app/dataload/dataloader.py -v \
					--mapfile=/app/config/AIRR-iReceptorMapping.txt \
					--host=$DB_HOST \
					--database=$DB_DATABASE \
					--repertoire_collection sample \
					--rearrangement_collection sequence \
					--cell_collection cell \
					--$CELL_TYPE \
					-f /scratch/$FILE_NAME' \
 	2>&1 | tee $LOG_FILE

TIME2=`date +%Y-%m-%d_%H-%M-%S`
echo "Finished at: $TIME2"
