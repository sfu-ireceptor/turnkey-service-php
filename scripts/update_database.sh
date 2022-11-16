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

${SCRIPT_DIR}/update_adc_date_fields.sh
${SCRIPT_DIR}/update_collection_time_point_relative.sh collection_time_point_relative
${SCRIPT_DIR}/update_dates.sh sample '%a %b %d %Y %H:%M:%S %Z'
${SCRIPT_DIR}/update_keywords_study.sh keywords_study single_cell ir_sequence_count
${SCRIPT_DIR}/update_template_amount.sh template_amount

echo "Done"
echo
