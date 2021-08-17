#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

MONGO_VERSION=`sudo docker-compose --file  ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec -T ireceptor-database sh -c 'mongo --quiet --eval "db.version()" $MONGO_INITDB_DATABASE'`

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

# update database to Mongo 4.4 if necessary
${SCRIPT_DIR}/upgrade_mongo.sh $MONGO_VERSION

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

# delete stopped containers and dangling images
echo "Removing old Docker images and containers.."
sudo docker system prune --force
echo "Done"
echo

# confirm successful installation
echo "Congratulations, your iReceptor Service Turnkey has been updated successfully."
echo "For more information, go to https://github.com/sfu-ireceptor/turnkey-service-php"
