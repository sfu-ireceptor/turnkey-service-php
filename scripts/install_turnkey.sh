#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# install Docker
echo "Installing Docker.."
sudo ${SCRIPT_DIR}/install_docker.sh > /dev/null 2>&1
echo "Done"
echo


# install Docker Compose
echo "Installing Docker Compose.."
sudo curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose > /dev/null 2>&1
sudo chmod +x /usr/local/bin/docker-compose
echo "Done"
echo


# download Docker images from Docker Hub
echo "Downloading Docker images from Docker Hub.."
sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service pull
echo "Done"
echo

# start Docker containers
${SCRIPT_DIR}/start_turnkey.sh
