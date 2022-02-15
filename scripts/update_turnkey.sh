#!/bin/bash

SCRIPT_DIR=`dirname "$0"`

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
echo "Downloading AIRR-iReceptor mapping ${MAPPING_URL}"
mkdir -p ${SCRIPT_DIR}/../.config
curl -# -o ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping_new.txt $MAPPING_URL

# if there wasn't any config file
if [ ! -f ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping.txt ]; then
	cp ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping_new.txt ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping.txt
fi

# if the new config file is different
if [[ `diff --brief ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping_new.txt ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping.txt` != '' ]]
then
	CURRENT_DATETIME=`date +%Y-%m-%d_%H-%M-%S`
	ARCHIVED_NAME=AIRR-iReceptorMapping_${CURRENT_DATETIME}.txt
	mv ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping.txt ${SCRIPT_DIR}/../.config/${ARCHIVED_NAME}
	cp ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping_new.txt ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping.txt
	ARCHIVED_PATH=`realpath ${SCRIPT_DIR}/../.config/${ARCHIVED_NAME}`
	echo "INFO: the mapping has been updated"
	echo "INFO: the previous mapping has been archived to $ARCHIVED_PATH"
fi

rm ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping_new.txt

echo "Done"
echo


# generate and install self-signed SSL certificate for HTTPS
SSL_FOLDER="${SCRIPT_DIR}/../.ssl"
if [[ ! -e $SSL_FOLDER ]]; then
	echo "Installing self-signed SSL certificate.."
	mkdir -p $SSL_FOLDER
	openssl rand -out ~/.rnd -hex 256
	openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
	    -subj "/C=CA/ST=BC/L=Vancouver/O=iReceptor/CN=ireceptor-turnkey" \
	    -keyout $SSL_FOLDER/private-key.pem  -out $SSL_FOLDER/certificate.pem
	cp $SSL_FOLDER/certificate.pem $SSL_FOLDER/intermediate.pem
	echo "Done"
	echo
fi


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

# confirm successful installation
echo "Congratulations, your iReceptor Service Turnkey has been updated successfully."
echo "For more information, go to https://github.com/sfu-ireceptor/turnkey-service-php"
