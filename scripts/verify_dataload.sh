#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# Get the command line arguements
if [ $# -eq 5 ]
then
    base_url="$1"
    metadata="$2"
    study_id="$3" 
    study_dir="$4"
    output_dir="$5"
else
    echo "usage: $0 base_url metadata study_id study_dir output_dir"
    exit
fi

# make available to docker-compose.yml
export base_url
export metadata
export study_dir
export study_id
export entry_point
export json_facet
export no_filters
export mapping_file
export output_dir

# Get the filename of metadata file. Note this container mounts the 
# FILE_FOLDER directory as /scratch, and anything that is in $FILE_FOLDER
# will be available on /scratch within the container. This means that the
# FILE_NAME is available as /scratch/$FILE_NAME inside the container.
FILE_ABSOLUTE_PATH=`realpath "$metadata"`
FILE_FOLDER=`dirname "$FILE_ABSOLUTE_PATH"`
FILE_NAME=`basename "$FILE_ABSOLUTE_PATH"`

# create log file
LOG_FOLDER=${SCRIPT_DIR}/../log
mkdir -p $LOG_FOLDER
TIME1=`date +%Y-%m-%d_%H-%M-%S`
LOG_FILE=${LOG_FOLDER}/${TIME1}_${FILE_NAME}.log

# -----------------------------------------------------------------------------------#
# Sanity check for mapping and AIRR library version - this changes with time though, might be worth to remove echo message, or update script accordingly
echo "Mapping file from branch ipa5-v3 https://github.com/sfu-ireceptor/config"
echo "AIRR test version Tag v1.3.0"

# -----------------------------------------------------------------------------------#
# Notes:
# sudo -E: make current environment variables available to the command run as root
# docker-compose --rm: delete container afterwards 
# docker-compose -e: these variables will be available inside the container (but not accessible in docker-compose.yml)
# "ireceptor-dataloading" is the service name defined in docker-compose.yml 
# sh -c '...' is the command executed inside the container
echo "Generating JSON input files - then running ADC API repertoire test"
echo $output_dir
echo $study_dir
echo $FILE_FOLDER
echo $FILE_NAME
echo $metadata
sudo -E docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service run -v $study_dir:/study -v $output_dir:/output --rm \
			-e base_url="$base_url" \
			-e entry_point="$entry_point" \
			-e json_facet="$json_facet" \
			-e no_filters="$no_filters" \
			-e study_id="$study_id" \
			-e mapping_file="$mapping_file" \
			-e metadata="$metadata" \
			-e study_dir="$study_dir"\
			-e details_dir="$details_dir" \
                        -e FILE_FOLDER="$FILE_FOLDER" \
                        -e FILE_NAME="$FILE_NAME" \
			ireceptor-dataloading \
				sh -c 'ls /scratch ; file /scratch/${FILE_NAME} ; bash /app/verify/joint_sanity_testing.sh \
                                        ${base_url} \
                                        "repertoire" \
                                        /app/verify/facet_queries_for_sanity_tests/ \
					/app/verify/nofilters.json \
					${study_id} \
					/app/config/AIRR-iReceptorMapping.txt \
					/study/${FILE_NAME} \
					/study/ \
					/output/ ' \
 	2>&1 | tee $LOG_FILE
