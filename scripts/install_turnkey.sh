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


# download images from Docker Hub, build and start containers
echo "Downloading (pulling) Docker images from Docker Hub.."
${SCRIPT_DIR}/start_turnkey.sh
echo "Done"
echo
