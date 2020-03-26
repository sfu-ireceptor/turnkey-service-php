#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# Get the command line arguements
if [ $# -eq 5 ]
then
    METADATA_FILE="$1"
    API_URL="$2"
    STUDY_ID="$3"
    ANNOTATION_DIR="$4"
    UNIQUE_ID_FIELD="$5"
else
    echo "usage: $0 metadata_file API_url_address study_id annotation_dir unique_identifier"
    exit
fi



# make available to docker-compose.yml
export METADATA_FILE
export API_URL
export STUDY_ID
export ANNOTATION_DIR
export UNIQUE_ID_FIELD

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
			-e API_URL="$API_URL" \
			-e STUDY_ID="$STUDY_ID" \
			-e ANNOTATION_DIR="$ANNOTATION_DIR" \
			-e UNIQUE_ID_FIELD="$UNIQUE_ID_FIELD" \
			ireceptor-dataloading \
				sh -c 'python /app/verify/sanitychecking.py \
                                        $METADATA_FILE \
                                        $API_URL \
                                        $STUDY_ID \
                                        $ANNOTATION_DIR \
                    					$API_URL \
                                        L \
					$UNIQUE_ID_FIELD '\
 	2>&1 | tee $LOG_FILE

