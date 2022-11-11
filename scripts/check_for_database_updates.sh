#!/bin/bash

SCRIPT_DIR=`dirname "$0"`
SCRIPT_DIR_FULL="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

DATABASE_NEEDS_TO_BE_UPDATED=0
temp_file=$(mktemp)

if [ $DATABASE_NEEDS_TO_BE_UPDATED -eq 0 ]; then
	${SCRIPT_DIR}/update_dates.sh sample '%a %b %d %Y %H:%M:%S %Z' check > ${temp_file}
	NEEDS_UPDATE=`cat ${temp_file}`
	if [ $NEEDS_UPDATE = "1" ]; then
		DATABASE_NEEDS_TO_BE_UPDATED=1
	fi
fi

rm ${temp_file}
echo $DATABASE_NEEDS_TO_BE_UPDATED

