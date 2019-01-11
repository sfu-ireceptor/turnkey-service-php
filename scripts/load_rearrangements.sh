#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

REARRANGEMENT_TYPE="$1"
shift

${SCRIPT_DIR}/drop_database_indexes.sh

while [ "$1" != "" ]; do
	FILE="$1"
	${SCRIPT_DIR}/load_one_rearrangement.sh "$REARRANGEMENT_TYPE" "$FILE"
	shift
done

${SCRIPT_DIR}/create_database_indexes.sh
