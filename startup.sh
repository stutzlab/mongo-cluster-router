#!/bin/bash
set -e
# set -x

if [ "$CONFIG_SERVER_NODES" == "" ]; then
    echo "CONFIG_SERVER_NODES is required"
    exit 1
fi

PASSWORD_FILE="/run/secrets/$ROOT_PASSWORD_SECRET"
if [ "$ROOT_USERNAME" != "" ]; then
    if [ "$ROOT_PASSWORD_SECRET" == "" ]; then
        echo "ROOT_PASSWORD_SECRET is required when ROOT_USERNAME is defined"
        exit 1
    fi
    if [ ! -f "$PASSWORD_FILE" ]; then
        echo "ROOT_USERNAME was defined but password file could not be found at $PASSWORD_FILE"
        exit 1
    fi
fi

SHAREDKEY_FILE="/run/secrets/$SHARED_KEY_SECRET"
if [ "$SHARED_KEY_SECRET" != "" ]; then
    if [ ! -f "$SHAREDKEY_FILE" ]; then
        echo "SHARED_KEY_SECRET was defined but no secret found at $SHAREDKEY_FILE"
        exit 1
    fi
    cp $SHAREDKEY_FILE /sharedkey
    chmod 600 /sharedkey
fi

/config.sh &

IFS=',' read -r -a NODES <<< "$CONFIG_SERVER_NODES"
S=""
export CONFIGDB=""
for N in "${NODES[@]}"; do
    echo "Config node $N"
    export CONFIGDB="${CONFIGDB}${S}$N:27017"
    S=","
done


export AE=""
if [ "$SHARED_KEY_SECRET" != "" ]; then
    export AE="--keyFile /sharedkey"
fi

echo ">>> Starting Mongo router..."
set -x
mongos --port 27017 $AE --configdb $CONFIG_REPLICA_SET/$CONFIGDB --bind_ip_all

