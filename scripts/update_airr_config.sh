#!/bin/bash

# Get our execution directory. Config is relative to script dir for Turnkey
SCRIPT_DIR=`dirname "$0"`

# load config file
source ${SCRIPT_DIR}/config.sh

# update config file
CONFIG_FOLDER="${SCRIPT_DIR}/../.config"
echo "Downloading AIRR-iReceptor mapping ${MAPPING_URL}"
mkdir -p $CONFIG_FOLDER
sudo chmod 777 $CONFIG_FOLDER
curl -# -o $CONFIG_FOLDER/AIRR-iReceptorMapping_new.txt $MAPPING_URL

# if there wasn't any config file
if [ ! -f $CONFIG_FOLDER/AIRR-iReceptorMapping.txt ]; then
        cp $CONFIG_FOLDER/AIRR-iReceptorMapping_new.txt $CONFIG_FOLDER/AIRR-iReceptorMapping.txt
fi

# if the new config file is different
if [[ `diff --brief $CONFIG_FOLDER/AIRR-iReceptorMapping_new.txt $CONFIG_FOLDER/AIRR-iReceptorMapping.txt` != '' ]]
then
        CURRENT_DATETIME=`date +%Y-%m-%d_%H-%M-%S`
        ARCHIVED_NAME=AIRR-iReceptorMapping_${CURRENT_DATETIME}.txt
        mv $CONFIG_FOLDER/AIRR-iReceptorMapping.txt $CONFIG_FOLDER/${ARCHIVED_NAME}
        cp $CONFIG_FOLDER/AIRR-iReceptorMapping_new.txt $CONFIG_FOLDER/AIRR-iReceptorMapping.txt
        ARCHIVED_PATH=`realpath $CONFIG_FOLDER/${ARCHIVED_NAME}`
        echo "INFO: the mapping has been updated"
        echo "INFO: the previous mapping has been archived to $ARCHIVED_PATH"
fi

rm $CONFIG_FOLDER/AIRR-iReceptorMapping_new.txt

echo "Done"
echo

