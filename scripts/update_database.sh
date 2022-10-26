#!/bin/bash

SCRIPT_DIR=`dirname "$0"`
SCRIPT_DIR_FULL="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# check for database updates
echo "Checking if the database needs to be updated.."
DATABASE_NEEDS_TO_BE_UPDATED=`${SCRIPT_DIR}/check_for_database_updates.sh`
echo "Done"
echo

# if no update is required
if [ $DATABASE_NEEDS_TO_BE_UPDATED != '1' ]; then
	echo "No update is needed, your database appears to be up to date."
	exit 0
fi

# run any updates
echo "Updating the database.."
# TODO run update scripts
echo "Done"
echo
