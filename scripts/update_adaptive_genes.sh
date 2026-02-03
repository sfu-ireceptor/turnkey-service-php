#!/bin/bash

SCRIPT_DIR=`dirname "$0"`
SCRIPT_FILE_NAME=`basename "$0"`

# check number of arguments
if [[ $# -ne 3 ]];
then
    echo "$0: wrong number of arguments ($#)"
    echo "usage: $0 gene_field allele_field field_map"
    exit 1
fi

GENE_FIELD=$1
ALLELE_FIELD=$2
FIELD_MAP=$3

FILE_ABSOLUTE_PATH=`realpath "$3"`
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
# docker compose --rm: delete container afterwards 
# docker compose -e: these variables will be available inside the container
# (but not accessible in docker-compose.yml)
# "ireceptor-dataloading" is the service name defined in docker-compose.yml 
# sh -c '...' is the command executed inside the container
# $DB_HOST and $DB_DATABASE are defined in docker-compose.yml and will be
# substituted only when the python command is executed, INSIDE the container
sudo -E docker compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service run --rm \
	                        -e FILE_NAME="$FILE_NAME" \
	                        -e FILE_FOLDER="$FILE_FOLDER" \
				-e GENE_FIELD="${GENE_FIELD}" \
				-e ALLELE_FIELD="${ALLELE_FIELD}"\
				-e FIELD_MAP="$FIELD_MAP" \
			ireceptor-dataloading  \
				sh -c 'python /app/dataload/update_adaptive_genes.py \
				        --mapfile=/app/config/AIRR-iReceptorMapping.txt \
                                        --host=$DB_HOST \
                                        --database=$DB_DATABASE \
                                        --repertoire_collection sample \
                                        --rearrangement_collection sequence \
					--verbose \
					$GENE_FIELD \
					$ALLELE_FIELD \
					/scratch/$FILE_NAME \
					'\
 	2>&1  | tee $LOG_FILE

TIME2=`date +%Y-%m-%d_%H-%M-%S`
echo "Finished at: $TIME2"

