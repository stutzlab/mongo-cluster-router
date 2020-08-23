#!/bin/sh

echo "ROOT USER CREATION/UPDATE"

if [ "$ROOT_PASSWORD_SECRET" != "" ]; then

    PASSWORD_FILE="/run/secrets/$ROOT_PASSWORD_SECRET"

    echo "db.getUser('admin')" | mongo 127.0.0.1/admin | grep null
    if [ "$?" == 1 ]; then
        echo "Root user already exists. Updating password"

tee "/updateuser.js" > /dev/null <<EOF
use admin
db.updateUser( "$ROOT_USERNAME", {
                pwd: "$(cat $PASSWORD_FILE)",
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
db.createUser( { user: "$ROOT_USERNAME",
                pwd: "$(cat $PASSWORD_FILE)",
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
