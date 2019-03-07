#!/bin/sh

SCRIPT_DIR=`dirname "$0"`

# Default number of iterations through the test
count=3

# Get the command line arguements, the number of iterations, the DB name,
# the DB host, and the DB port to use.
if [ $# -eq 5 ]
then
    count=$1
    db_name=$2
    db_host=$3
    db_port=$4
    out_folder=$5
else
    echo "usage: $0 count db host port out_folder"
    exit
fi

# The Javascript files to use for the performance test.
APP_DIR="/app/benchmark"
perf_js_file="$APP_DIR/test_performance_explain.js"
cache_js_file="$APP_DIR/cache_dump.js"
index_js_file="$APP_DIR/index_dump.js"
# The host we are running on
host_name=$(hostname)

# Get the current time for the start of the overall performance test.
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
echo "Test performed at: $current_time"

# Dump the indexes. This is important to know as if the performance
# is not as good as expected this can help diagnose the problem.
sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml \
        --project-name turnkey-service run ireceptor-performance-testing \
        sh -c "mongo $db_name --host $db_host --port $db_port $index_js_file" \
        > $out_folder/index-$host_name-$db_host-$db_port-$db_name-$current_time.txt

# Dump the query plan cache. This is important to know as if the performance
# is not as good as expected this can help diagnose the problem.
sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml \
        --project-name turnkey-service run ireceptor-performance-testing \
        sh -c "mongo $db_name --host $db_host --port $db_port $cache_js_file" \
        > $out_folder/cache-$host_name-$db_host-$db_port-$db_name-$current_time.txt

# Perform the benchmark test the number of times requested.
for i in `seq 1 $count`;
do
    # Run the performance test once. Output file is named such that it is
    # possible to track down where (and when) a performance file came from
    echo "Performing test iteration $i"
    sudo docker-compose --file ${SCRIPT_DIR}/docker-compose.yml \
        --project-name turnkey-service run ireceptor-performance-testing \
        sh -c "mongo $db_name --host $db_host --port $db_port $perf_js_file" \
        > $out_folder/run$i-$host_name-$db_host-$db_port-$db_name-$current_time.txt
done

# Print out the time when the test run finished.
end_time=$(date "+%Y.%m.%d-%H.%M.%S")
echo "Test finished at: $end_time"

