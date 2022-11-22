#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# FILE_FOLDER is mapped to /scratch inside the container (see docker compose).
# We need the file by itself (FILE_MAP) because it is read in the conatiner
# relative to /scratch.
FILE_ABSOLUTE_PATH=`realpath "$1"`
FILE_FOLDER=`dirname "$FILE_ABSOLUTE_PATH"`
FILE_MAP=`basename "$FILE_ABSOLUTE_PATH"`

#REARRANGEMENT_FILE_NAME=$1
#CELL_FILE_NAME=$2

# make available to docker-compose.yml
export FILE_FOLDER

# create log file
LOG_FOLDER=${SCRIPT_DIR}/../log
mkdir -p $LOG_FOLDER
TIME1=`date +%Y-%m-%d_%H-%M-%S`
LOG_FILE=${LOG_FOLDER}/${TIME1}_${FILE_MAP}.log

#echo "Linking data from ${REARRANGEMENT_FILE_NAME} to ${CELL_FILE_NAME}" 
echo "Linking data from files in ${FILE_MAP}" 
echo "Starting at: $TIME1"

# Notes:
# sudo -E: make current environment variables available to the command run as root
# docker-compose --rm: delete container afterwards 
# docker-compose -e: these variables will be available inside the container (but not accessible in docker-compose.yml)
# "ireceptor-dataloading" is the service name defined in docker-compose.yml 
# sh -c '...' is the command executed inside the container
# $DB_HOST and $DB_DATABASE are defined in docker-compose.yml and will be substituted only when the python command is executed, INSIDE the container
sudo -E docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service run --rm \
			-e FILE_MAP="$FILE_MAP" \
			ireceptor-dataloading \
				sh -c 'python /app/dataload/link_rearrangement2cell.py -v \
					--mapfile=/app/config/AIRR-iReceptorMapping.txt \
					--host=$DB_HOST \
					--database=$DB_DATABASE \
					--repertoire_collection sample \
					--rearrangement_collection sequence \
					/scratch/${FILE_MAP}' \
 	2>&1 | tee $LOG_FILE

			#-e REARRANGEMENT_FILE_NAME="$REARRANGEMENT_FILE_NAME" \
			#-e CELL_FILE_NAME="$CELL_FILE_NAME" \
					#--rearrangement_file $REARRANGEMENT_FILE_NAME \
					#--cell_file $CELL_FILE_NAME' \

TIME2=`date +%Y-%m-%d_%H-%M-%S`
echo "Finished at: $TIME2"
