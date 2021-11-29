#!/bin/sh

SCRIPT_DIR=`dirname "$0"`
SCRIPT_DIR_FULL="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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

# install SSL certificate
echo "Updating SSL certificate.."
mkdir -p ${SCRIPT_DIR_FULL}/../.ssl
cp ${SCRIPT_DIR_FULL}/../ssl/default/*.pem ${SCRIPT_DIR_FULL}/../.ssl
echo "Done"
echo

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
