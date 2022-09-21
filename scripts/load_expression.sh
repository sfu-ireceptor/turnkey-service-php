#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# check number of arguments
NB_ARGS=2
if [ $# -lt $NB_ARGS ];
then
    echo "$0: wrong number of arguments ($# instead of at least $NB_ARGS)"
    echo "usage: $0 (airr-expression) <airr_expression_file.json> [<airr_expression_file2.json> ...]"
    exit 1
fi

echo -n "Starting $0: "
date

CELL_TYPE="$1"
shift

${SCRIPT_DIR}/drop_expression_database_indexes_for_dataloading.sh

while [ "$1" != "" ]; do
	FILE="$1"
	${SCRIPT_DIR}/load_one_expression.sh "$CELL_TYPE" "$FILE"
	shift
done

${SCRIPT_DIR}/create_expression_database_indexes.sh

echo -n "Done $0: "
date
