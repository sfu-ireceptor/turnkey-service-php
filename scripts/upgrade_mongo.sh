#!/bin/bash

SCRIPT_DIR=`dirname "$0"`
SCRIPT_DIR_FULL="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

# current mongodb version
MONGO_VERSION=`sudo docker-compose --file  ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service exec -T ireceptor-database sh -c 'mongo --quiet --eval "db.version()" $MONGO_INITDB_DATABASE'`
# MONGO_VERSION=3.9

# Need to upgrade to MongoDB 4.0?
vercomp 4.0 $MONGO_VERSION
CMP=$?
if [[ $CMP = 1 ]]
    then
        echo "Need to upgrade"
    else
        echo "No need to upgrade"
fi


# stop Docker containers
echo "Stopping Docker containers.."
${SCRIPT_DIR}/stop_turnkey.sh
echo "Done"
echo

# pull mongo image 4.0
#sudo docker run -v ${SCRIPT_DIR_FULL}/../.mongodb_data:/data/db ireceptor/repository-mongodb:mongo4.0


#sudo docker run --name mongo4.0 -v ${SCRIPT_DIR_FULL}/../.mongodb_data:/data/db ireceptor/repository-mongodb:mongo4.0

#sudo docker run --name mongo4.0 -v ${SCRIPT_DIR_FULL}/../.mongodb_data:/data/db --rm -i -t ireceptor/repository-mongodb:mongo4.0 bash
sudo docker run --name mongo4.0 -v ${SCRIPT_DIR_FULL}/../.mongodb_data:/data/db --rm -d -t ireceptor/repository-mongodb:mongo4.0
# docker exec -it mongo4.0 sh -c 'mongo --quiet --eval "db.version()" $MONGO_INITDB_DATABASE'
docker exec -it mongo4.0 sh -c 'mongo --quiet --eval "db.adminCommand({setFeatureCompatibilityVersion:\"4.0\"})" $MONGO_INITDB_DATABASE'
# docker exec -it mongo4.0 sh -c 'mongo --quiet --eval "db.adminCommand({setFeatureCompatibilityVersion:4.0})" $MONGO_INITDB_DATABASE'

# db.adminCommand({setFeatureCompatibilityVersion:"4.0"})

# sudo docker run --name ubuntu_bash --rm -i -t ubuntu bash


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
echo "Congratulations, your MongoDB database has been upgraded successfully."
echo "For more information, go to https://github.com/sfu-ireceptor/turnkey-service-php"
