#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# Get the command line arguements
if [ $# -eq 4 ]
then
    base_url="$1"
    master_md="$2"
    annotation_dir="$3"
    study_id="$4" 
else
    echo "usage: $0 base_url master_md annotation_dir study_id"
    exit
fi

# make available to docker-compose.yml
export base_url
export master_md
export annotation_dir
export study_id

# create log file
LOG_FOLDER=${SCRIPT_DIR}/../log
mkdir -p $LOG_FOLDER
TIME1=`date +%Y-%m-%d_%H-%M-%S`
LOG_FILE=${LOG_FOLDER}/${TIME1}_${FILE_NAME}.log

# -----------------------------------------------------------------------------------#
# Sanity check for mapping and AIRR library version - this changes with time though, might be worth to remove echo message, or update script accordingly
echo "Mapping file from branch ipa5-v3 https://github.com/sfu-ireceptor/config"
echo "AIRR test version Tag v1.3.0"
echo ${base_url}
echo ${master_md}
echo ${annotation_dir}
echo ${study_id}
# -----------------------------------------------------------------------------------#
# Notes:
# sudo -E: make current environment variables available to the command run as root
# docker-compose --rm: delete container afterwards 
# docker-compose -e: these variables will be available inside the container (but not accessible in docker-compose.yml)
# "ireceptor-dataloading" is the service name defined in docker-compose.yml 
# sh -c '...' is the command executed inside the container
echo "Generating JSON input files - then running ADC API repertoire test"
sudo -E docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service run -v /data:/data --rm \
			-e base_url="$base_url" \
			-e entry_point="$entry_point" \
			-e json_facet="$json_facet" \
			-e no_filters="$no_filters" \
			-e study_id="$study_id" \
			-e mapping_file="$mapping_file" \
			-e master_md="$master_md" \
			-e annotation_dir="$annotation_dir"\
			-e details_dir="$details_dir" \
			ireceptor-dataloading \
				sh -c 'bash /app/verify/joint_sanity_testing.sh \
                                        ${base_url} \
                                        "repertoire" \
                                        /app/verify/facet_queries_for_sanity_tests/ \ 
					/app/verify/nofilters.json \
					${study_id} \
					/app/config/AIRR-iReceptorMapping.txt \
					${master_md} \
					${annotation_dir} \
					${LOG_FOLDER}' \
 	2>&1 | tee $LOG_FILE
