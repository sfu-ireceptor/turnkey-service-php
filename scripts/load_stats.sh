#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# Get the command line arguements. Script assumes that study_dir is a directory
# and that the directory contains both the $metadata_file as well as all of the
# annotation files. The output from the command is written to $output_dir.
if [ $# -eq 1 ]
then
    study_id="$1" 
else
    echo "usage: $0 study_id"
    exit
fi

# Make available to docker-compose.yml
export study_id

# create log file
LOG_FOLDER=${SCRIPT_DIR}/../log
mkdir -p $LOG_FOLDER
TIME=`date +%Y-%m-%d_%H-%M-%S`
LOG_FILE=${LOG_FOLDER}/${TIME}_${metadata_file}.log

# Check to make sure the files and directories exist.
stats_dir=/tmp/$$-${TIME}
if [ -d "$stats_dir" ]; then
    echo "ERROR: Temporary stats directory already exists: $stats_dir."
    exit 1
fi
mkdir ${stats_dir}

if [ ! -d "$stats_dir" ]; then
    echo "ERROR: Could nor create temporary directory $stats_dir."
    exit 1
fi

# Tell the user what is going on.
echo "Starting stats generation at $TIME"
echo "    Generating stats for study $study_id"
echo "    Temporary directory = $stats_dir"

# -----------------------------------------------------------------------------------#
# Notes:
# sudo -E: make current environment variables available to the command run as root
# docker-compose --rm: delete container afterwards 
# docker-compose -e: these variables will be available inside the container (but not accessible in docker-compose.yml)
# docker-compose -v: mount VM volumes in the container. We mount $study_dir where all the input is and $output_dir where the output is written
# "ireceptor-dataloading" is the service name defined in docker-compose.yml 
# sh -c '...' is the command executed inside the container
#sudo -E docker-compose --file ${SCRIPT_DIR}/docker-compose.yml \
#	               --project-name turnkey-service run \
#		       -v /data:/data -v $stats_dir:/outdir --rm \
#		       -e study_id="$study_id" \
#		       ireceptor-api \
#		       sh -c 'php /data/src/dataloading-mongo/stats/stats_files_create.php \
#			        ${study_id} /outdir'\
# 	2>&1 | tee $LOG_FILE
#
#sudo -E docker-compose --file ${SCRIPT_DIR}/docker-compose.yml \
#	               --project-name turnkey-service run \
#		       -v /data:/data -v $stats_dir:/outdir --rm \
#		       ireceptor-api \
#		       sh -c 'php /data/src/dataloading-mongo/stats/stats_files_load.php \
#			         /outdir/*.json'\
# 	2>&1 | tee $LOG_FILE

sudo -E docker-compose --file ${SCRIPT_DIR}/docker-compose.yml \
	               --project-name turnkey-service run \
		       -v /data:/data \
		       -v $stats_dir:/outdir --rm \
		       -e study_id="$study_id" \
		       ireceptor-api \
		       sh -c 'bash /data/src/dataloading-mongo/stats/load_stats_mongo.sh \
			         ${study_id} /outdir'\
 	2>&1 | tee $LOG_FILE

# Get a new time and tell the user we are done.
TIME=`date +%Y-%m-%d_%H-%M-%S`
# rm -rf $stats_dir
echo "Finished stats generation for $study_id at $TIME"
