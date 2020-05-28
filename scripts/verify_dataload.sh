#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# Get the command line arguements
if [ $# -eq 10 ]
then
    mapping_file="$1"
    base_url="$2"
    entry_point="$3"
    json_files="$4"
    master_md="$5"
    study_id="$6"
    facet_count="$7"
    annotation_dir="$8"
    details_dir="$9"
    Coverage="$10"
else
    echo "usage: $0 metadata_file API_url_address study_id annotation_dir unique_identifier"
    exit
fi



# make available to docker-compose.yml
export mapping_file
export base_url
export entry_point
export json_files
export master_md
export study_id
export facet_count
export annotation_dir
export details_dir
export Coverage 

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
			-e mapping_file="$mapping_file" \
			-e base_url="$base_url" \
			-e entry_point="$entry_point" \
			-e json_files="$json_files" \
			-e master_md="$master_md" \
			-e study_id="$study_id" \
			-e facet_count="$facet_count" \
			-e annotation_dir="$annotation_dir" \
			-e details_dir="$details_dir" \
			-e Coverage="$Coverage" \
			ireceptor-dataloading \
				sh -c 'python /app/verify/AIRR-repertoire-checks.py \
                                        $mapping_file \
                                        $base_url \
                                        $entry_point \
                                        $json_files \
                    			$master_md \
					$study_id \
					$facet_count \
                                        $annotation_dir \
					$details_dir \
					$CC-FC '\
 	2>&1 | tee $LOG_FILE

