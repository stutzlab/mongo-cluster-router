#!/bin/bash

echo "Waiting for local server to be available at 27017..."
while ! nc -z 127.0.0.1 27017; do sleep 0.5; done
sleep 1

echo "Generating router config"
echo ""
rm /init-addshards.js
for i in {1..100}; do 
    SHARD_REPLICA_SET_NAME="${ADD_SHARD_REPLICA_SET_PREFIX}$i"
    var="ADD_SHARD_${i}_NODES"
    SNODES="${!var}"

    if [ "$SNODES" == "" ]; then
        continue
    fi
    IFS=',' read -r -a NODES <<< "$SNODES"
    S=""
    echo "Shard ${SHARD_REPLICA_SET_NAME} nodes:"
    for N in "${NODES[@]}"; do
        echo "    - $N"
        echo "sh.addShard(\"$SHARD_REPLICA_SET_NAME/$N:27017\")" >> /addshards.js
        CONFIGDB="${CONFIGDB}${S}$N:27017"
        S=","
    done
done
echo ""

echo "/addshards.js"
cat /addshards.js

echo "ADDING SHARDS TO CLUSTER..."
mongo < /addshards.js
echo ">>> SHARDS ADDED SUCCESSFULLY"

