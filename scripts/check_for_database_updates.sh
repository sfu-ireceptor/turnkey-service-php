#!/bin/bash

SCRIPT_DIR=`dirname "$0"`
SCRIPT_DIR_FULL="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

DATABASE_NEEDS_TO_BE_UPDATED=0
temp_file=$(mktemp)

if [ $DATABASE_NEEDS_TO_BE_UPDATED -eq 0 ]; then
	${SCRIPT_DIR}/update_adc_date_fields.sh check > ${temp_file}
	NEEDS_UPDATE=`cat ${temp_file}`
	NEEDS_UPDATE="${NEEDS_UPDATE//[$'\t\r\n ']}"
	if [ $NEEDS_UPDATE == "1" ]; then
		DATABASE_NEEDS_TO_BE_UPDATED=1
	fi
fi

if [ $DATABASE_NEEDS_TO_BE_UPDATED -eq 0 ]; then
	${SCRIPT_DIR}/update_collection_time_point_relative.sh collection_time_point_relative check > ${temp_file}
	NEEDS_UPDATE=`cat ${temp_file}`
	NEEDS_UPDATE="${NEEDS_UPDATE//[$'\t\r\n ']}"
	if [ $NEEDS_UPDATE == "1" ]; then
		DATABASE_NEEDS_TO_BE_UPDATED=1
	fi
fi

if [ $DATABASE_NEEDS_TO_BE_UPDATED -eq 0 ]; then
	${SCRIPT_DIR}/update_dates.sh sample '%a %b %d %Y %H:%M:%S %Z' check > ${temp_file}
	NEEDS_UPDATE=`cat ${temp_file}`
	NEEDS_UPDATE="${NEEDS_UPDATE//[$'\t\r\n ']}"
	if [ $NEEDS_UPDATE == "1" ]; then
		DATABASE_NEEDS_TO_BE_UPDATED=1
	fi
fi

if [ $DATABASE_NEEDS_TO_BE_UPDATED -eq 0 ]; then
	${SCRIPT_DIR}/update_keywords_study.sh keywords_study single_cell ir_sequence_count check > ${temp_file}
	NEEDS_UPDATE=`cat ${temp_file}`
	NEEDS_UPDATE="${NEEDS_UPDATE//[$'\t\r\n ']}"
	if [ $NEEDS_UPDATE == "1" ]; then
		DATABASE_NEEDS_TO_BE_UPDATED=1
	fi
fi

if [ $DATABASE_NEEDS_TO_BE_UPDATED -eq 0 ]; then
	${SCRIPT_DIR}/update_template_amount.sh template_amount check > ${temp_file}
	NEEDS_UPDATE=`cat ${temp_file}`
	NEEDS_UPDATE="${NEEDS_UPDATE//[$'\t\r\n ']}"
	if [ $NEEDS_UPDATE == "1" ]; then
		DATABASE_NEEDS_TO_BE_UPDATED=1
	fi
fi

rm ${temp_file}
echo $DATABASE_NEEDS_TO_BE_UPDATED

