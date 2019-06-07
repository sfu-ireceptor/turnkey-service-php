#!/bin/sh

SCRIPT_DIR=`dirname "$0"`
APACHE_LOG_FOLDER="${SCRIPT_DIR}/../.apache_log"

mkdir -p "${APACHE_LOG_FOLDER}"

echo "Dumping Apache logs"
sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service logs ireceptor-api > "${APACHE_LOG_FOLDER}/access.log"

echo "Done"
echo

