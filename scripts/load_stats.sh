#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# Get the command line arguements. Script takes a study_id to determine
# which study to generate stats for.
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
# docker compose --rm: delete container afterwards 
# docker compose -e: these variables will be available inside the container (but not accessible in docker-compose.yml)
# docker compose -v: mount VM volumes in the container. 
# "ireceptor-dataloading" is the service name defined in docker-compose.yml 
# sh -c '...' is the command executed inside the container

sudo -E docker compose --file ${SCRIPT_DIR}/docker-compose.yml \
	               --project-name turnkey-service run \
		       -v $stats_dir:/outdir --rm \
		       -e study_id="$study_id" \
		       ireceptor-dataloading \
		       sh -c 'bash /app/stats/load_stats_mongo.sh ${study_id} /outdir'\
 	2>&1 | tee $LOG_FILE

# Get a new time and tell the user we are done.
TIME=`date +%Y-%m-%d_%H-%M-%S`
rm -rf $stats_dir
echo "Finished stats generation for $study_id at $TIME"
