#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

if [ $# -ne 1 ];
then
    echo "usage: $0 [metadata file ...]"
    exit 1
fi

FILE_ABSOLUTE_PATH=`realpath "$1"`
FILE_FOLDER=`dirname "$FILE_ABSOLUTE_PATH"`
FILE_NAME=`basename "$FILE_ABSOLUTE_PATH"`

# make available to docker-compose.yml
export FILE_FOLDER

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
			ireceptor-dataloading  \
				sh -c 'python /app/scripts/dataloader.py \
					--mapfile=/app/config/AIRR-iReceptorMapping.txt \
			 		--host=$DB_HOST \
			 		--database=$DB_DATABASE \
			 		--sample \
			 		-f /scratch/$FILE_NAME'
