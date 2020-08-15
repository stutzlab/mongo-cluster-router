#!/bin/sh

set -e

nc -z 127.0.0.1 27017

if [ ! -f "/data/__initialized" ]; then
    echo "Node not initialized yet"
    set +e
    R=$(echo 'sh.status().ok' | mongo localhost:27017/test --quiet)
    E=$?
    if [ "$E" = "0" ]; then
        if [ "$R" = "1" ]; then
            touch /data/__initialized
        fi
    fi

else
    echo "Node already initialized. make deep check"
    #check for shard status
    R=$(echo 'sh.status().ok' | mongo localhost:27017/test --quiet)
    echo $R | grep 1 
fi
