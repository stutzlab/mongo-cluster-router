#!/bin/bash

echo "Waiting for local server to be available at 27017..."
while ! nc -z 127.0.0.1 27017; do sleep 0.5; done
echo "Mongo OK"
sleep 1

if [ "$MONGO_INITDB_ROOT_USERNAME" != "" ]; then

    echo "db.getUser('admin')" | mongo 127.0.0.1/admin | grep null
    if [ "$?" == 1 ]; then
        echo "Root user already exists. Updating password"

tee "/updateuser.js" > /dev/null <<EOF
use admin
db.updateUser( "$MONGO_INITDB_ROOT_USERNAME", {
                pwd: "$(cat $MONGO_INITDB_ROOT_PASSWORD_FILE)",
                roles: [ { role: "root", db: "admin" } ] 
                }
            )
EOF

        set -e
        echo /updateuser.js
        mongo < /updateuser.js
        set +e
        echo "ROOT USER UPDATED"

    else

tee "/createuser.js" > /dev/null <<EOT
use admin
db.createUser( { user: "$MONGO_INITDB_ROOT_USERNAME",
                pwd: "$(cat $MONGO_INITDB_ROOT_PASSWORD_FILE)",
                roles: [ { role: "root", db: "admin" } ] 
                }
            )
EOT

        set -e
        echo /createuser.js
        mongo < /createuser.js
        set +e
        echo "ROOT USER CREATED"

    fi
fi


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
mongo < /addshards.js
echo ">>> SHARDS ADDED"

