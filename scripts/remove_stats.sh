#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

echo -n "Starting $0: "
date

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

echo "Removing stats for study $study_id"

# Remove stats
sudo -E docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec -T -e study_id="$study_id" ireceptor-database  \
	sh -c 'cd /app && bash /app/scripts/remove_stats.sh ${study_id}'

echo -n "Done $0: "
date
