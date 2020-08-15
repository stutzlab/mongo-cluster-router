#!/bin/sh

nc -z 127.0.0.1 27017

echo "Check shards status"
R=$(echo 'sh.status().ok' | mongo localhost:27017/test --quiet)
if [ "$?" != "0" ]; then
    echo "Cannot query mongo"
    exit 1
fi
if [ "$R" != "1" ]; then
    echo "sh.status() not OK"
    exit 1
fi

