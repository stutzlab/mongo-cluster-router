#!/bin/bash
set -e
# set -x

if [ "$CONFIG_SERVER_NODES" == "" ]; then
    echo "CONFIG_SERVER_NODES is required"
    exit 1
fi

if [ "$MONGO_INITDB_ROOT_USERNAME" != "" ]; then
    if [ ! -f $MONGO_INITDB_ROOT_PASSWORD_FILE ]; then
        echo "MONGO_INITDB_ROOT_USERNAME was defined but password file could not be found at $MONGO_INITDB_ROOT_PASSWORD_FILE"
        exit 1
    fi
fi

/config.sh &

IFS=',' read -r -a NODES <<< "$CONFIG_SERVER_NODES"
S=""
CONFIGDB=""
for N in "${NODES[@]}"; do
    echo "Config node $N"
    CONFIGDB="${CONFIGDB}${S}$N:27017"
    S=","
done

echo ">>> Starting Mongo router..."
mongos --port 27017 --configdb $CONFIG_REPLICA_SET/$CONFIGDB --bind_ip_all

