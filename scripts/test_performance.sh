#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml --project-name turnkey-service run ireceptor-performance-testing '/app/benchmark/cache_dump.js'
