#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# Get the command line arguements
if [ $# -eq 3 ]
then
    base_url="$1"
    master_md="$2"
    annotation_dir="$3"
else
    echo "usage: $0 base_url master_md annotation_dir"
    exit
fi

# make available to docker-compose.yml
export base_url
export master_md
export annotation_dir
export study_id
export mapping_file
export json_files
export facet_count
export Coverage
export details_dir
export entry_point

# create log file
LOG_FOLDER=${SCRIPT_DIR}/../log
mkdir -p $LOG_FOLDER
TIME1=`date +%Y-%m-%d_%H-%M-%S`
LOG_FILE=${LOG_FOLDER}/${TIME1}_${FILE_NAME}.log

# -----------------------------------------------------------------------------------#
# Sanity check for mapping and AIRR library version
echo "Mapping file from branch ipa5-v3 https://github.com/sfu-ireceptor/config"
echo "AIRR test version Tag v1.3.0"

# -----------------------------------------------------------------------------------#
# Mapping file
git clone https://github.com/sfu-ireceptor/config
cd config/
git pull
git checkout ipa5-v3
# Get mapping file
mapping_file=${PWD}"/AIRR-iReceptorMapping.txt"

# Cleanup 
cd ../
rm -r -f config/

cd ${SCRIPT_DIR}

# -----------------------------------------------------------------------------------#
# JSON input handling
git clone https://github.com/sfu-ireceptor/dataloading-mongo
cd dataloading-mongo/verify/
# Get No filters query
no_filters=${PWD}"/nofilters.json"
cd facet_queries_for_sanity_tests/
# Get Path to JSON files (facet queries)
json_facet=$PWD

cd ${SCRIPT_DIR}

# -----------------------------------------------------------------------------------#
# Misc variables 
entry_point="repertoire"
details_dir=${SCRIPT_DIR}

# -----------------------------------------------------------------------------------#
# Generate JSON
# Notes:
# sudo -E: make current environment variables available to the command run as root
# docker-compose --rm: delete container afterwards 
# docker-compose -e: these variables will be available inside the container (but not accessible in docker-compose.yml)
# "ireceptor-dataloading" is the service name defined in docker-compose.yml 
# sh -c '...' is the command executed inside the container
sudo -E docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service run -v /data:/data --rm \
			-e base_url="$base_url" \
			-e entry_point="$entry_point" \
			-e json_files="$no_filters" \
			ireceptor-dataloading \
				sh -c 'python /app/verify/generate_facet_json.py \
                                        $base_url \
                                        $entry_point \
                                        $no_filters \
 	2>&1 | tee $LOG_FILE

cd ${SCRIPT_DIR}

sudo -E docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service run -v /data:/data --rm \
			-e mapping_file="$mapping_file" \
			-e base_url="$base_url" \
			-e entry_point="$entry_point" \
			-e json_files="$no_filters" \
			-e master_md="$master_md" \
			-e study_id="$study_id" \
			-e facet_count="$json_facet" \
			-e annotation_dir="$annotation_dir" \
			-e details_dir="$details_dir" \
			-e Coverage="$Coverage" \
			ireceptor-dataloading \
				sh -c 'python /app/verify/AIRR-repertoire-checks.py \
                                        $mapping_file \
                                        $base_url \
                                        $entry_point \
                                        $no_filters \
                    			$master_md \
					$study_id \
					$json_facet \
                                        $annotation_dir \
					$details_dir \
					$CC-FC '\
 	2>&1 | tee $LOG_FILE

