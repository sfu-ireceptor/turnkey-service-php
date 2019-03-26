#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

METADATA_FILE="$1"
API_FILE="$2"
STUDY_ID="$3"
ANNOTATION_DIR="$4"

# make available to docker-compose.yml
export METADATA_FILE
export API_FILE
export STUDY_ID
export ANNOTATION_DIR

# create log file
LOG_FOLDER=${SCRIPT_DIR}/../log
mkdir -p $LOG_FOLDER
TIME1=`date +%Y-%m-%d_%H-%M-%S`
LOG_FILE=${LOG_FOLDER}/${TIME1}_${FILE_NAME}.log

# Notes:
# sudo -E: make current environment variables available to the command run as root
# docker-compose --rm: delete container afterwards 
# docker-compose -e: these variables will be available inside the container (but not accessible in docker-compose.yml)
# "ireceptor-dataloading" is the service name defined in docker-compose.yml 
# sh -c '...' is the command executed inside the container
sudo -E docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service run -v /data:/data --rm \
			-e METADATA_FILE="$METADATA_FILE" \
			-e API_FILE="$API_FILE" \
			-e STUDY_ID="$STUDY_ID" \
			-e ANNOTATION_DIR="$ANNOTATION_DIR" \
			ireceptor-dataloading \
				sh -c 'python /app/verify/sanitychecking.py \
                                        $METADATA_FILE \
                                        $API_FILE \
                                        $STUDY_ID \
                                        $ANNOTATION_DIR \
                                        L' \
 	2>&1 | tee $LOG_FILE

