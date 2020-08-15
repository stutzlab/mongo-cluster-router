#!/bin/sh

function deepCheck() {
    #check for shard status
    R=$(echo 'sh.status().ok' | mongo localhost:27017/test --quiet)
    echo $R | grep 1
    return $?
}

set -e
nc -z 127.0.0.1 27017
set +e

if [ ! -f "/data/__initialized" ]; then
    echo "Node not initialized yet"
    R=$(deepCheck)
    if [ "$R" = "0" ]; then
        touch /data/__initialized
    fi
    exit 0
fi

echo "Node already initialized. make deep check"
R=$(deepCheck)
exit $R

