#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# install Docker
echo "Disabling HTTPS.."
sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec -T ireceptor-api \
		sh -c 'a2dissite -q 000-default.conf && a2ensite -q http.conf && service apache2 reload'
echo "Done"
echo


