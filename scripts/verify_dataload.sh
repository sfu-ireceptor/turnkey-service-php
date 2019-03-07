#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

METADATA_FILE="$1"
API_FILE="$2"
SAMPLE_ID="$3"
ANNOTATION_DIR="$4"

#FILE_ABSOLUTE_PATH=`realpath "$2"`
#FILE_FOLDER=`dirname "$FILE_ABSOLUTE_PATH"`
#FILE_NAME=`basename "$FILE_ABSOLUTE_PATH"`

# make available to docker-compose.yml
export METADATA_FILE
export API_FILE
export SAMPLE_ID
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
# $DB_HOST and $DB_DATABASE are defined in docker-compose.yml and will be substituted only when the python command is executed, INSIDE the container
sudo -E docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service run -v /data:/data --rm \
			-e METADATA_FILE="$METADATA_FILE" \
			-e API_FILE="$API_FILE" \
			-e SAMPLE_ID="$SAMPLE_ID" \
			-e ANNOTATION_DIR="$ANNOTATION_DIR" \
			ireceptor-dataloading \
				sh -c 'pip install requests; pip install xlrd; python /app/verify/sanitychecking.py \
                                        $METADATA_FILE \
                                        $API_FILE \
                                        $SAMPLE_ID \
                                        $ANNOTATION_DIR \
                                        LH' \
 	2>&1 | tee $LOG_FILE
