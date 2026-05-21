#!/bin/sh

SCRIPT_DIR=`dirname "$0"`
sudo docker compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service stop

echo
echo "Stopping AWStats..."
sudo docker stop awstats > /dev/null 2>&1 && sudo docker rm awstats > /dev/null 2>&1
echo "Done"
echo
