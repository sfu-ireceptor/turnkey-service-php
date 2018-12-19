#!/bin/sh

export FILE_FOLDER=`dirname "$1"`
export FILE_NAME=`basename "$1"`

sudo -E docker-compose run  \
			-e FILE_NAME="$FILE_NAME" \
			-e FILE_FOLDER="$FILE_FOLDER" \
			ireceptor-dataloading  \
				sh -c 'python /app/scripts/dataloader.py \
					--mapfile=/app/config/AIRR-iReceptorMapping.txt \
			 		--host=$DB_HOST \
			 		--database=$DB_DATABASE \
			 		--sample \
			 		-f /scratch/$FILE_NAME'
