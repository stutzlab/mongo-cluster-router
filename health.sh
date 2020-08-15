#!/bin/sh

deepCheck() {
    #check for shard status
    R=$(echo 'sh.status().ok' | mongo localhost:27017/test --quiet)
    if [ "$?" != "0" ]; then
        echo "1"
        return
    fi
    echo $R | grep 1
    echo $?
}

set -e
nc -z 127.0.0.1 27017
set +e

if [ ! -f "/data/__initialized" ]; then
    echo "Service is up. shard not initialized yet"
    E=$(deepCheck)
    if [ "$E" = "0" ]; then
        echo "Marking this as initialized"
        touch /data/__initialized
    fi
    exit 0
fi

echo "Service is up. shard initialized. making deep check"
R=$(deepCheck)
exit $R

