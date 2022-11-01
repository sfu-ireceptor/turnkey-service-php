#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# check number of arguments
NB_ARGS=2
if [ $# -lt $NB_ARGS ];
then
    echo "$0: wrong number of arguments ($# instead of at least $NB_ARGS)"
    echo "usage: $0 (airr|imgt|mixcr) <rearrangement_file> [<another_rearrangement_file> ...]"
    exit 1
fi

echo -n "Starting $0: "
date

REARRANGEMENT_TYPE="$1"
shift

${SCRIPT_DIR}/drop_rearrangement_database_indexes_dataloading.sh

while [ "$1" != "" ]; do
	FILE="$1"
	${SCRIPT_DIR}/load_one_rearrangement.sh "$REARRANGEMENT_TYPE" "$FILE"
	shift
done

echo -n "Done $0: "
date
