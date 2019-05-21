#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

echo "Starting iReceptor Service Turnkey.."
sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service up -d
echo "Done"
echo

# The Mongo query plans are forgotten each time mongo is stopped.
# They need to be recreated at startup.
${SCRIPT_DIR}/create_database_queryplans.sh
echo
