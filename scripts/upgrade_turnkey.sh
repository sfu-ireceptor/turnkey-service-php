#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# stop Docker containers
echo "Stopping Docker containers.."
${SCRIPT_DIR}/stop_turnkey.sh
echo "Done"
echo


# update local git repository
echo "Upgrading source code.."
git pull
echo "Done"
echo


# download latest Docker images from Docker Hub
echo "Downloading Docker images from Docker Hub.."
sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service pull
echo "Done"
echo


# start Docker containers
echo "Starting Docker containers.."
${SCRIPT_DIR}/start_turnkey.sh
echo "Done"
echo

# confirm successful installation
echo "Congratulations, your iReceptor Service Turnkey has been upgraded successfully."
echo "For more information, go to https://github.com/sfu-ireceptor/turnkey-service-php"
