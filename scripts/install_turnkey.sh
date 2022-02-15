#!/bin/bash

SCRIPT_DIR=`dirname "$0"`
SCRIPT_DIR_FULL="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# load config file
source ${SCRIPT_DIR}/config.sh

# install Docker
echo "Installing Docker.."
if [ -x "$(command -v docker)" ]; then
	echo "Already installed."
  else
	sudo ${SCRIPT_DIR}/install_docker.sh > /dev/null 2>&1
	echo "Done"
fi
echo

# install Docker Compose
echo "Installing Docker Compose.."
if [ -x "$(command -v docker-compose)" ]; then
	echo "Already installed."
  else
	sudo curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose > /dev/null 2>&1
	sudo chmod +x /usr/local/bin/docker-compose
	echo "Done"
fi
echo

# MongoDB optimization
# https://docs.mongodb.com/manual/tutorial/transparent-huge-pages/
echo 'Installing system service to disable Transparent Huge Pages (recommended by MongoDB)..'
sudo cp ${SCRIPT_DIR}/disable-transparent-hugepages /etc/init.d/disable-transparent-hugepages
sudo update-rc.d disable-transparent-hugepages defaults
sudo service disable-transparent-hugepages start
echo "Done"
echo

# download Docker images from Docker Hub
echo "Downloading Docker images from Docker Hub.."
sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service pull
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

# launch on boot
STARTUP_FILE='/etc/rc.local'
echo "Add code to launch on boot in $STARTUP_FILE .."
if [[ -f "$STARTUP_FILE" ]]; then
	OLD_STARTUP_FILE='/etc/rc.local.old'
    echo "Warning: $STARTUP_FILE already exists, moving it to $OLD_STARTUP_FILE"
    sudo mv "$STARTUP_FILE" "$OLD_STARTUP_FILE"
fi
echo '#!/bin/bash' | sudo tee $STARTUP_FILE > /dev/null
echo "${SCRIPT_DIR_FULL}/start_turnkey.sh" | sudo tee -a $STARTUP_FILE > /dev/null
sudo chmod +x $STARTUP_FILE
echo "Done"
echo

# install config file
echo "Downloading AIRR-iReceptor mapping.."
mkdir -p ${SCRIPT_DIR_FULL}/../.config
curl -# -o ${SCRIPT_DIR_FULL}/../.config/AIRR-iReceptorMapping.txt $MAPPING_URL
echo "Done"
echo

# start turnkey
${SCRIPT_DIR}/start_turnkey.sh
echo

# confirm successful installation
echo "Congratulations, your iReceptor Service Turnkey is up and running."
echo "For more information, go to https://github.com/sfu-ireceptor/turnkey-service-php"
