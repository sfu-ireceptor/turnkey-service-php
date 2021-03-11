#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# check number of arguments
NB_ARGS=2
if [ $# -lt $NB_ARGS ];
then
    echo "$0: wrong number of arguments ($# instead of at least $NB_ARGS)"
    echo "usage: $0 (mixcr-clone) <clone_file> [<another_clone_file> ...]"
    exit 1
fi

echo -n "Starting $0: "
date

CLONE_TYPE="$1"
shift

${SCRIPT_DIR}/drop_clone_database_indexes_for_dataloading.sh

while [ "$1" != "" ]; do
	FILE="$1"
	${SCRIPT_DIR}/load_one_clone.sh "$CLONE_TYPE" "$FILE"
	shift
done

${SCRIPT_DIR}/create_clone_database_indexes.sh

echo -n "Done $0: "
date
