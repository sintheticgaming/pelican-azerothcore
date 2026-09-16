#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later

set -euo pipefail

CONF_DIR="${CONF_DIR:-/home/container/etc}"

# Required database variables.
: "${DB_HOST:?DB_HOST is required}"
: "${DB_PORT:?DB_PORT is required}"
: "${DB_USER:?DB_USER is required}"
: "${DB_PASSWORD:?DB_PASSWORD is required}"
: "${DB_AUTH:?DB_AUTH is required}"
: "${DB_CHARACTERS:?DB_CHARACTERS is required}"
: "${DB_WORLD:?DB_WORLD is required}"

# Required realm variables.
: "${REALM_NAME:?REALM_NAME is required}"
: "${REALM_ADDRESS:?REALM_ADDRESS is required}"
: "${REALM_LOCAL_ADDRESS:?REALM_LOCAL_ADDRESS is required}"
: "${REALM_LOCAL_SUBNET_MASK:?REALM_LOCAL_SUBNET_MASK is required}"

# Validate realm values before using them in SQL.
if [[ ! "$REALM_NAME" =~ ^[A-Za-z0-9._[:space:]-]+$ ]]; then
    echo "ERROR: REALM_NAME contains unsupported characters."
    exit 1
fi

if [[ ! "$REALM_ADDRESS" =~ ^[A-Za-z0-9._:-]+$ ]]; then
    echo "ERROR: REALM_ADDRESS contains unsupported characters."
    exit 1
fi

if [[ ! "$REALM_LOCAL_ADDRESS" =~ ^[A-Fa-f0-9.:]+$ ]]; then
    echo "ERROR: REALM_LOCAL_ADDRESS contains unsupported characters."
    exit 1
fi

if [[ ! "$REALM_LOCAL_SUBNET_MASK" =~ ^[0-9.]+$ ]]; then
    echo "ERROR: REALM_LOCAL_SUBNET_MASK contains unsupported characters."
    exit 1
fi

# Build AzerothCore database connection strings.
export AC_LOGIN_DATABASE_INFO="${DB_HOST};${DB_PORT};${DB_USER};${DB_PASSWORD};${DB_AUTH}"
export AC_CHARACTER_DATABASE_INFO="${DB_HOST};${DB_PORT};${DB_USER};${DB_PASSWORD};${DB_CHARACTERS}"
export AC_WORLD_DATABASE_INFO="${DB_HOST};${DB_PORT};${DB_USER};${DB_PASSWORD};${DB_WORLD}"

export AC_DISABLE_INTERACTIVE=1
export AC_CLOSE_IDLE_CONNECTIONS=0

# Initialize or migrate the AzerothCore databases before starting the servers.
echo "Checking AzerothCore databases..."

ACORE_COMPONENT=dbimport \
AC_UPDATES_ENABLE_DATABASES=7 \
dbimport -c "${CONF_DIR}/dbimport.conf"

echo "Database initialization/update completed."

# Configure realm ID 1.
echo "Configuring AzerothCore realm..."

MYSQL_CNF="$(mktemp)"

cleanup_mysql_cnf() {
    rm -f "$MYSQL_CNF"
}

trap cleanup_mysql_cnf EXIT
chmod 600 "$MYSQL_CNF"

cat > "$MYSQL_CNF" <<EOF
[client]
host=${DB_HOST}
port=${DB_PORT}
user=${DB_USER}
password=${DB_PASSWORD}
EOF

mysql \
    --defaults-extra-file="$MYSQL_CNF" \
    "$DB_AUTH" \
    --execute="
        UPDATE realmlist
        SET
            name = '${REALM_NAME}',
            address = '${REALM_ADDRESS}',
            localAddress = '${REALM_LOCAL_ADDRESS}',
            localSubnetMask = '${REALM_LOCAL_SUBNET_MASK}',
            port = 8085
        WHERE id = 1;
    "

rm -f "$MYSQL_CNF"
trap - EXIT

echo "Realm configuration updated."

# dbimport owns database migrations. Runtime services should not independently
# apply database updates.
export AC_UPDATES_ENABLE_DATABASES=0

echo "Starting AzerothCore authserver..."
ACORE_COMPONENT=authserver \
authserver -c "${CONF_DIR}/authserver.conf" </dev/null &

echo "Starting AzerothCore worldserver..."
export ACORE_COMPONENT=worldserver

exec worldserver -c "${CONF_DIR}/worldserver.conf"
