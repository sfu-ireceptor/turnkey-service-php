#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

echo "Enabling HTTPS.."
sudo docker compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec -T ireceptor-api \
		sh -c 'a2dissite -q http.conf && a2ensite -q 000-default.conf && service apache2 reload'
echo "Done"
echo


