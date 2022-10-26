#!/bin/bash

SCRIPT_DIR=`dirname "$0"`
SCRIPT_DIR_FULL="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# load config file
source ${SCRIPT_DIR}/config.sh

# stop Docker containers
echo "Stopping Docker containers.."
${SCRIPT_DIR}/stop_turnkey.sh
echo "Done"
echo

# update local git repository
echo "Updating source code.."
git -C ${SCRIPT_DIR} pull
echo "Done"
echo

# download latest Docker images from Docker Hub
echo "Downloading Docker images from Docker Hub.."
sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service pull
echo "Done"
echo

# update config file
CONFIG_FOLDER="${SCRIPT_DIR}/../.config"
echo "Downloading AIRR-iReceptor mapping ${MAPPING_URL}"
mkdir -p $CONFIG_FOLDER
sudo chmod 777 $CONFIG_FOLDER
curl -# -o $CONFIG_FOLDER/AIRR-iReceptorMapping_new.txt $MAPPING_URL

# if there wasn't any config file
if [ ! -f $CONFIG_FOLDER/AIRR-iReceptorMapping.txt ]; then
	cp $CONFIG_FOLDER/AIRR-iReceptorMapping_new.txt $CONFIG_FOLDER/AIRR-iReceptorMapping.txt
fi

# if the new config file is different
if [[ `diff --brief $CONFIG_FOLDER/AIRR-iReceptorMapping_new.txt $CONFIG_FOLDER/AIRR-iReceptorMapping.txt` != '' ]]
then
	CURRENT_DATETIME=`date +%Y-%m-%d_%H-%M-%S`
	ARCHIVED_NAME=AIRR-iReceptorMapping_${CURRENT_DATETIME}.txt
	mv $CONFIG_FOLDER/AIRR-iReceptorMapping.txt $CONFIG_FOLDER/${ARCHIVED_NAME}
	cp $CONFIG_FOLDER/AIRR-iReceptorMapping_new.txt $CONFIG_FOLDER/AIRR-iReceptorMapping.txt
	ARCHIVED_PATH=`realpath $CONFIG_FOLDER/${ARCHIVED_NAME}`
	echo "INFO: the mapping has been updated"
	echo "INFO: the previous mapping has been archived to $ARCHIVED_PATH"
fi

rm $CONFIG_FOLDER/AIRR-iReceptorMapping_new.txt

echo "Done"
echo


# generate and install self-signed SSL certificate for HTTPS
SSL_FOLDER="${SCRIPT_DIR}/../.ssl"
if [[ ! -e $SSL_FOLDER ]]; then
	echo "Creating SSL folder.."
	mkdir -p $SSL_FOLDER
	echo "Done"
	echo
fi

SSL_FOLDER_CONTENTS=`ls -A $SSL_FOLDER`
if [ -z "$SSL_FOLDER_CONTENTS" ]; then
	echo "Installing self-signed SSL certificate.."
	sudo chmod 777 $SSL_FOLDER
	openssl rand -out ~/.rnd -hex 256
	openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
	    -subj "/C=CA/ST=BC/L=Vancouver/O=iReceptor/CN=ireceptor-turnkey" \
	    -keyout $SSL_FOLDER/private-key.pem  -out $SSL_FOLDER/certificate.pem
	cp $SSL_FOLDER/certificate.pem $SSL_FOLDER/intermediate.pem
	echo "Done"
	echo
fi

# start on boot using systemd
SYSTEMD_SERVICE_FILE='/etc/systemd/system/ireceptor-turnkey.service'
echo "Creating systemd service to start turnkey on boot.."
echo "[Unit]" | sudo tee $SYSTEMD_SERVICE_FILE > /dev/null
echo "Description=iReceptor Turnkey" | sudo tee -a $SYSTEMD_SERVICE_FILE > /dev/null
echo "Requires=docker.service" | sudo tee -a $SYSTEMD_SERVICE_FILE > /dev/null
echo "After=docker.service" | sudo tee -a $SYSTEMD_SERVICE_FILE > /dev/null
echo "" | sudo tee -a $SYSTEMD_SERVICE_FILE > /dev/null
echo "[Service]" | sudo tee -a $SYSTEMD_SERVICE_FILE > /dev/null
echo "ExecStart=${SCRIPT_DIR_FULL}/start_turnkey.sh" | sudo tee -a $SYSTEMD_SERVICE_FILE > /dev/null
echo "TimeoutStartSec=0" | sudo tee -a $SYSTEMD_SERVICE_FILE > /dev/null
echo "Restart=on-failure" | sudo tee -a $SYSTEMD_SERVICE_FILE > /dev/null
echo "StartLimitIntervalSec=60" | sudo tee -a $SYSTEMD_SERVICE_FILE > /dev/null
echo "StartLimitBurst=3" | sudo tee -a $SYSTEMD_SERVICE_FILE > /dev/null
echo "" | sudo tee -a $SYSTEMD_SERVICE_FILE > /dev/null
echo "[Install]" | sudo tee -a $SYSTEMD_SERVICE_FILE > /dev/null
echo "WantedBy=multi-user.target" | sudo tee -a $SYSTEMD_SERVICE_FILE > /dev/null
echo "Done"
echo
echo "Enabling ireceptor-turneky systemd service startup on boot.."
sudo systemctl enable ireceptor-turnkey.service
echo "Done"
echo

# if .home folder exists, but is owned by root, it needs to be deleted
if [[ -e "${SCRIPT_DIR_FULL}/../.home" ]]; then
	home_folder_owner="$(stat --format '%U' "${SCRIPT_DIR_FULL}/../.home")"
	if [ "${home_folder_owner}" = 'root' ]; then
	    sudo rmdir ${SCRIPT_DIR_FULL}/../.home
	fi
fi

# create .home folder (owned by current user) if needed
mkdir -p ${SCRIPT_DIR_FULL}/../.home

# start Docker containers
echo "Starting Docker containers.."
${SCRIPT_DIR}/start_turnkey.sh
echo "Done"
echo

# delete stopped containers and dangling images
echo "Removing old Docker images and containers.."
sudo docker system prune --force
echo "Done"
echo

# check for database updates
echo "Checking if the database needs to be updated.."
DATABASE_NEEDS_TO_BE_UPDATED=`${SCRIPT_DIR}/check_for_database_updates.sh`
if [ $DATABASE_NEEDS_TO_BE_UPDATED == '1' ]; then
	echo "Warning: the version 1.3 of the AIRR standards requires some database updates."
	echo "Please run scripts/update_database.sh as soon as possible. It will take about two hours."
	exit 0
fi
echo "Done"
echo

# confirm successful installation
echo "Congratulations, your iReceptor Service Turnkey has been updated successfully."
echo "For more information, go to https://github.com/sfu-ireceptor/turnkey-service-php"
echo
echo "Note: HTTPS is enabled. If you prefer not use HTTPS (not recommended), run disable_https.sh"
