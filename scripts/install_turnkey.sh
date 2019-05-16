#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

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

# install and enable system service
cp ${SCRIPT_DIR}/ireceptor_turnkey.service /etc/systemd/system/ireceptor_turnkey.service
sudo systemctl enable /etc/systemd/system/ireceptor_turnkey.service

# start turnkey
echo "Starting iReceptor Service Turnkey.."
sudo systemctl start ireceptor_turnkey.service
echo "Done"
echo

# confirm successful installation
echo "Congratulations, your iReceptor Service Turnkey is up and running."
echo "For more information, go to https://github.com/sfu-ireceptor/turnkey-service-php"
