#!/bin/sh

SCRIPT_DIR=`dirname "$0"`
sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service up -d
echo

# The Mongo query plans are forgotten each time mongo is stopped.
# They need to be recreated at startup.
${SCRIPT_DIR}/create_database_queryplans.sh
echo

# MongoDB optimization
echo 'Setting "transparent_hugepage" to "never" (recommended by MongoDB)..'
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/defrag > /dev/null
echo "Done"
