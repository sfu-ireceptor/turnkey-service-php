#!/bin/sh

SCRIPT_DIR=`dirname "$0"`
APACHE_LOG_FOLDER="${SCRIPT_DIR}/../.apache_log"
AWSTATS_FOLDER="${SCRIPT_DIR}/../.awstats"

# retrieve absolute paths (required by Docker)
APACHE_LOG_FOLDER=$(cd $APACHE_LOG_FOLDER; pwd)
AWSTATS_FOLDER==$(cd $AWSTATS_FOLDER; pwd)

mkdir -p "${APACHE_LOG_FOLDER}"
mkdir -p "${AWSTATS_FOLDER}"

echo "Delete any existing AWStats container..."
sudo docker stop awstats && sudo docker rm awstats
echo "Done"
echo

echo "Dumping iReceptor Turnkey API container log into ${APACHE_LOG_FOLDER}..."
sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service logs ireceptor-api | cut -f2 -d'|' > "${APACHE_LOG_FOLDER}/access.log"
echo "Done"
echo

echo "Starting AWStats container..."
sudo docker run \
    --detach \
    --restart always \
    --publish 8088:80 \
    --name awstats \
    --env AWSTATS_CONF_LOGFORMAT=' %host %other %logname %time1 %methodurl %code %bytesd %refererquot %uaquot' \
    --volume "${APACHE_LOG_FOLDER}":/var/local/log:ro \
    --volume "${AWSTATS_FOLDER}":/var/lib/awstats \
    pabra/awstats
echo "Done"
echo

echo "Running AWStats..."
sudo docker exec awstats awstats_updateall.pl now
echo "Done"
echo

# confirm success
echo "Your web statistics are now available at http://localhost:8088"
echo 'Note: you may need to replace "localhost" by this machine hostname'
