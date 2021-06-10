#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

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
echo "Downloading AIRR-iReceptor mapping.."
mkdir -p ${SCRIPT_DIR}/../.config
curl -# -o ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping_new.txt https://raw.githubusercontent.com/sfu-ireceptor/config/clone-and-stats-mapping/AIRR-iReceptorMapping.txt

if [[ `diff -q ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping_new.txt ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping.txt` != '' ]]
then
	mv ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping.txt ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping.old.txt
	mv ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping_new.txt ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping.txt
	echo "The mapping was updated, the previous file has been archived to ${SCRIPT_DIR}/../.config/AIRR-iReceptorMapping.old.txt"
fi

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
