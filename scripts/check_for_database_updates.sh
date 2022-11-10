#!/bin/bash

SCRIPT_DIR=`dirname "$0"`
SCRIPT_DIR_FULL="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

DATABASE_NEEDS_TO_BE_UPDATED=0

# TODO run database update check scripts

echo $DATABASE_NEEDS_TO_BE_UPDATED