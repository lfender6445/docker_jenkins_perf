#!/bin/bash

WAIT_INTERVAL=15
MAX_WAIT=300
RESULTS_FORMAT=xml

# hostname for python server for test runs/fetches
PERF_HOST=server

# internal port (not the port mapped to localhost, e.g. the second value in nnnn:mmmm)
PERF_PORT=8000
PERF_PROTO="http://"

read -d '' USAGE <<EOT
$0
    -w n    # wait n seconds between poll requests, default: $WAIT_INTERVAL seconds
    -m n    # wait n seconds between poll requests, default: $MAX_WAIT seconds
    -x      # retrieve xml version of results
    -c      # retrieve csv version of results
            # default: $RESULTS_FORMAT
    -h      # hostname for laod-test service, default: $PERF_HOST
    -p      # port on hostname for laod-test service, default: $PERF_PORT
    -v      # be verbose
    -?      # print usage
EOT

while getopts ":w:m:xcvh:p:" opt; do
    case "$opt" in
    \?)
        echo "$USAGE" 1>&2
        exit 0
        ;;
    v)  VERBOSE=1
        ;;
    w)  WAIT_INTERVAL=$OPTARG
        ;;
    m)  MAX_WAIT=$OPTARG
        ;;
    h)  PERF_HOST=$OPTARG
        ;;
    p)  PERF_PORT=$OPTARG
        ;;
    x)  RESULTS_FORMAT=xml
        ;;
    c)  RESULTS_FORMAT=csv
        ;;
    :)
        echo "Invalid option: $OPTARG requires an argument" 1>&2
        echo "$USAGE" 1>&2
        exit 1
        ;;
    esac
done

# needs apt-get install jq in the Dockerfile...


START_PATH="run_test"
START_URL="$PERF_PROTO$PERF_HOST:$PERF_PORT/$START_PATH"
START_CMD="wget -O - --quiet $START_URL"
if [ -v VERBOSE ]; then
    echo "Requesting run via \"$START_CMD\"" 1>&2
fi


RESPONSE=`$START_CMD`
if [ $? -ne 0 ]; then
    echo "$0: request for test start failed" 1>&2
    exit $?
fi

# fake response for now...
#RESPONSE='{"xml_route": "log/1524690082.0967674.xml", "csv_route": "log/1524690082.096786.csv"}'
XML_PATH=`echo "$RESPONSE" | jq .xml_route 2>/dev/null | sed -e s/\"//g 2>/dev/null`
CSV_PATH=`echo "$RESPONSE" | jq .csv_route 2>/dev/null | sed -e s/\"//g 2>/dev/null` 
if [[ -z "$XML_PATH" ||  -z "$CSV_PATH" ]]; then
    echo "$0: could not retrieve response paths from results" 1>&2
    echo "$0: command returned:" 1>&2
    echo "$RESPONSE" 1>&2
    exit 1
fi

# the xml, csv paths to poll
if [ -v VERBOSE ]; then
    echo "Response paths:" 1>&2
    echo "  XML=$XML_PATH" 1>&2
    echo "  CSV=$CSV_PATH" 1>&2
fi

POLL_URL="$PERF_PROTO$PERF_HOST:$PERF_PORT/$XML_PATH"
POLL_CMD="wget -O - --quiet $POLL_URL"
if [ -v VERBOSE ]; then
    echo "Polling via \"$POLL_CMD\"" 1>&2
fi

POLL_WAIT=0
until [[ $POLL_WAIT -ge $MAX_WAIT || -v DONE ]]; do
    STATS=`$POLL_CMD`
    GET_RESULT=$?
    if [ $GET_RESULT -eq 0 ]; then
        if [ -v VERBOSE ]; then
            echo "Done, after $POLL_WAIT seconds of max $MAX_WAIT" 1>&2
        fi
        DONE=true
    elif [ -v VERBOSE ]; then
        echo "Not done, after $POLL_WAIT seconds of max $MAX_WAIT" 1>&2
        sleep $WAIT_INTERVAL
        let POLL_WAIT+=$WAIT_INTERVAL
    fi
done

echo "STATS=$STATS"
RESULTS_PATH="$JENKINS_HOME/workspace/performance/performance-test.xml"
echo "RESULTS_PATH=$RESULTS_PATH"
echo "$STATS" > $RESULTS_PATH

exit 0

