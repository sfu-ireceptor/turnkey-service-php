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
if [ -x "$(command -v docker compose)" ]; then
	echo "Already installed."
  else

	compose_dir=""

	# Check where Docker Compose could be installed
	for dir in \
			"/usr/lib/docker/cli-plugins"\
			"/usr/local/lib/docker/cli-plugins" \
			"/usr/local/libexec/docker/cli-plugins" \
			"/usr/libexec/docker/cli-plugins"
	do
		echo "Checking if Docker Compose can be installed on $dir"
		if [ -d "$dir" ]; then
			echo "Docker compose can be installed on $dir"
			compose_dir=$dir
			break
		fi
	done

	# Fallback to user's home directory
	if [ -z "$compose_dir" ]; then
		compose_dir=$HOME/.docker/cli-plugins
		echo "System-wide directory for Docker CLI plugins was not found. Defaulting to home directory at $compose_dir"
	fi

	sudo curl -L https://github.com/docker/compose/releases/download/2.29.1/docker-compose-`uname -s`-`uname -m` -o $compose_dir/docker-compose > /dev/null 2>&1
	sudo chmod +x $compose_dir/docker-compose
	echo "Done"
fi
echo

# MongoDB optimization
# https://docs.mongodb.com/manual/tutorial/transparent-huge-pages/
echo 'Installing system service to disable Transparent Huge Pages (recommended by MongoDB)..'
sudo cp ${SCRIPT_DIR}/disable-transparent-hugepages /etc/init.d/disable-transparent-hugepages
sudo update-rc.d disable-transparent-hugepages defaults
sudo service disable-transparent-hugepages start
echo 'Created /etc/init.d/disable-transparent-hugepages'
echo "Done"
echo

# download Docker images from Docker Hub
echo "Downloading Docker images from Docker Hub.."
sudo docker compose -f ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service pull
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

# install config file
echo "Downloading AIRR-iReceptor mapping.."
mkdir -p ${SCRIPT_DIR_FULL}/../.config
curl -# -o ${SCRIPT_DIR_FULL}/../.config/AIRR-iReceptorMapping.txt $MAPPING_URL
echo "Done"
echo

# create home folder
mkdir -p ${SCRIPT_DIR_FULL}/../.home

# start turnkey
${SCRIPT_DIR}/start_turnkey.sh
echo

# confirm successful installation
echo "Congratulations, your iReceptor Service Turnkey is up and running."
echo "For more information, go to https://github.com/sfu-ireceptor/turnkey-service-php"
