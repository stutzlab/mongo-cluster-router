#!/bin/bash

echo "Waiting for local server to be available at 27017..."
while ! nc -z 127.0.0.1 27017; do sleep 0.5; done
echo "Mongo OK"
sleep 1

/createuser.sh

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
        echo ">>> Node $N"
        echo "sh.addShard(\"$SHARD_REPLICA_SET_NAME/$N:27017\")" >> /addshards.js
        CONFIGDB="${CONFIGDB}${S}$N:27017"
        S=","
        echo " - Waiting for host $N to be available..."
        until ping -c1 $N >/dev/null; do sleep 2; done
        echo " - Host available. Waiting port 27017..."
        while ! nc -z $N 27017; do sleep 1; done
        echo " - Host $N OK"
    done
done
echo ""

sleep 5

echo "/addshards.js"
cat /addshards.js

echo "ADDING SHARDS TO CLUSTER..."
if [ "$ROOT_USERNAME" != "" ]; then
  PASSWORD_FILE="/run/secrets/$ROOT_PASSWORD_SECRET"
  PASS=$(cat $PASSWORD_FILE)
  mongo mongodb://$ROOT_USERNAME:$PASS@localhost:27017 < /addshards.js
else
  mongo < /addshards.js
fi
echo ">>> SHARDS ADDED"

