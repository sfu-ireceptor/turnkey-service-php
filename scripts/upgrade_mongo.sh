#!/bin/bash

# Functions ############################################

# from https://stackoverflow.com/a/4025065/91225
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

# Main ################################################

SCRIPT_DIR=`dirname "$0"`
SCRIPT_DIR_FULL="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

MONGO_VERSION=$1

echo "Upgrading database.."

# If current MongoDB version >= 4.4, do nothing
vercomp 4.4 $MONGO_VERSION
CMP=$?
if [[ $CMP != 1 ]]
    then
        echo "Already using MongoDB 4.4, no need to upgrade."
        echo "Done"
        echo
        exit 0
fi

# If current MongoDB version < 4.0
vercomp 4.0 $MONGO_VERSION
CMP=$?
if [[ $CMP = 1 ]]
    then
        echo "Upgrading MongoDB database to 4.0.."
        sudo docker run --name mongo4.0 -v ${SCRIPT_DIR_FULL}/../.mongodb_data:/data/db --rm -d -t ireceptor/repository-mongodb:mongo4.0

        # wait for database to be ready to accept queries
        MONGO_DOWN=1
        while [[ $MONGO_DOWN = 1 ]]
        do
            echo '.'
            sleep 1
            sudo docker exec -it mongo4.0 sh -c 'mongo --quiet --eval "db.version()" $MONGO_INITDB_DATABASE'        
            MONGO_DOWN=$?
        done

        sudo docker exec -it mongo4.0 sh -c 'mongo --quiet --eval "db.adminCommand({setFeatureCompatibilityVersion:\"4.0\"})" $MONGO_INITDB_DATABASE'
        sudo docker stop mongo4.0
        MONGO_VERSION=4.0
        echo "Done"
        echo
fi

# If current MongoDB version < 4.2
vercomp 4.2 $MONGO_VERSION
CMP=$?
if [[ $CMP = 1 ]]
    then
        echo "Upgrading MongoDB database to 4.2.."
        sudo docker run --name mongo4.2 -v ${SCRIPT_DIR_FULL}/../.mongodb_data:/data/db --rm -d -t ireceptor/repository-mongodb:mongo4.2
        sleep 3 # wait for database to be ready to accept queries
        sudo docker exec -it mongo4.2 sh -c 'mongo --quiet --eval "db.adminCommand({setFeatureCompatibilityVersion:\"4.2\"})" $MONGO_INITDB_DATABASE'
        sudo docker stop mongo4.2
        MONGO_VERSION=4.2
        echo "Done"
        echo
fi

# If current MongoDB version < 4.4
vercomp 4.4 $MONGO_VERSION
CMP=$?
if [[ $CMP = 1 ]]
    then
        echo "Upgrading MongoDB database to 4.4.."
        sudo docker run --name mongo4.4 -v ${SCRIPT_DIR_FULL}/../.mongodb_data:/data/db --rm -d -t ireceptor/repository-mongodb:mongo4.4
        sleep 3 # wait for database to be ready to accept queries
        sudo docker exec -it mongo4.4 sh -c 'mongo --quiet --eval "db.adminCommand({setFeatureCompatibilityVersion:\"4.4\"})" $MONGO_INITDB_DATABASE'
        sudo docker stop mongo4.4
        MONGO_VERSION=4.4
        echo "Done"
        echo
fi
