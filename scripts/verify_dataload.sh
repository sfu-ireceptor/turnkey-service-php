#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# Get the command line arguements. Script assumes that study_dir is a directory
# and that the directory contains both the $metadata_file as well as all of the
# annotation files. The output from the command is written to $output_dir.
if [ $# -eq 6 ]
then
    study_id="$1" 
    study_dir="$2"
    metadata_file="$3"
    annotation_tool="$4"
    output_dir="$5"
    url="$6"
else
    echo "usage: $0 study_id study_dir metadata_file annotation_tool output_dir url"
    exit
fi

# Make available to docker-compose.yml
export study_id
export study_dir
export metadata_file
export annotation_tool
export output_dir
export url

# create log file
LOG_FOLDER=${SCRIPT_DIR}/../log
mkdir -p $LOG_FOLDER
TIME=`date +%Y-%m-%d_%H-%M-%S`
LOG_FILE=${LOG_FOLDER}/${TIME}_${metadata_file}.log

# Get the full path names for the directories. Docker requires this to mount them.
study_dir=`realpath $study_dir`
output_dir=`realpath $output_dir`

# Check to make sure the files and directories exist.
if [ ! -d "$study_dir" ]; then
    echo "ERROR: Input study directory $study_dir does not exist."
    exit 1
fi
if [ ! -d "$output_dir" ]; then
    echo "ERROR: Output study directory $output_dir does not exist."
    exit 1
fi
tmp_filename=$study_dir"/"$metadata_file
if [ ! -f "$tmp_filename" ]; then
    echo "ERROR: Metadata file $tmp_filename does not exist."
    exit 1
fi

STATUSCODE=$(curl --insecure --silent --output /dev/stderr --write-out "%{http_code}" ${url} 2> /dev/null)
if [ ${STATUSCODE} -ne 200 ]
then
    echo "ERROR: Could not contact repository ${url}"
    echo "HTTP Status = $STATUSCODE"
    curl --insecure ${url}
    exit 1
fi

# Replace localhost with the internal name within the docker environment.
if [ ${url} = "http://localhost" ] || [ ${url} = "http://localhost/" ]
then
    url="http://ireceptor-api"
fi

# Replace localhost with the internal name within the docker environment.
if [ ${url} = "https://localhost" ] || [ ${url} = "https://localhost/" ]
then
    url="https://ireceptor-api"
fi


# Tell the user what is going on.
echo "Starting data verification at $TIME"
echo "    Verifying study $study_id"
echo "    Study directory = $study_dir"
echo "    Metadata = $study_dir/$metadata_file"
echo "    Annotations = $study_dir"
echo "    Annotation tool = $annotation_tool"
echo "    Output directory = $output_dir"
echo "    Repository URL = $url"

# -----------------------------------------------------------------------------------#
# Notes:
# sudo -E: make current environment variables available to the command run as root
# docker compose --rm: delete container afterwards 
# docker compose -e: these variables will be available inside the container (but not accessible in docker-compose.yml)
# docker compose -v: mount VM volumes in the container. We mount $study_dir where all the input is and $output_dir where the output is written
# "ireceptor-dataloading" is the service name defined in docker-compose.yml 
# sh -c '...' is the command executed inside the container
				
sudo -E docker compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service run -v $study_dir:/study -v $output_dir:/output --rm \
			-e study_id="$study_id" \
			-e metadata_file="$metadata_file" \
			-e annotation_tool="$annotation_tool" \
			-e url="$url" \
			ireceptor-dataloading \
				sh -c 'bash /app/verify/joint_sanity_testing.sh \
                                        ${url} \
                                        "repertoire" \
                                        /app/verify/facet_queries_for_sanity_tests/ \
					/app/verify/nofilters.json \
					${study_id} \
					/app/config/AIRR-iReceptorMapping.txt \
					/study/${metadata_file} \
					/study/ \
					/output/  \
					${annotation_tool} '\
 	2>&1 | tee $LOG_FILE

# Get a new time and tell the user we are done.
TIME=`date +%Y-%m-%d_%H-%M-%S`
echo "Ouput from verification located in: $output_dir"
echo "Finished data verification at $TIME"
