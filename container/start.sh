#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later

set -euo pipefail
CONF_DIR="${CONF_DIR:-/home/container/etc}"

: "${DB_HOST:?DB_HOST is required}"
: "${DB_PORT:?DB_PORT is required}"
: "${DB_USER:?DB_USER is required}"
: "${DB_PASSWORD:?DB_PASSWORD is required}"
: "${DB_AUTH:?DB_AUTH is required}"
: "${DB_CHARACTERS:?DB_CHARACTERS is required}"
: "${DB_WORLD:?DB_WORLD is required}"

export AC_LOGIN_DATABASE_INFO="${DB_HOST};${DB_PORT};${DB_USER};${DB_PASSWORD};${DB_AUTH}"
export AC_CHARACTER_DATABASE_INFO="${DB_HOST};${DB_PORT};${DB_USER};${DB_PASSWORD};${DB_CHARACTERS}"
export AC_WORLD_DATABASE_INFO="${DB_HOST};${DB_PORT};${DB_USER};${DB_PASSWORD};${DB_WORLD}"

export AC_DISABLE_INTERACTIVE=1
export AC_CLOSE_IDLE_CONNECTIONS=0
export AC_ALE_BYTECODE_CACHE=1

echo "Checking AzerothCore databases..."
ACORE_COMPONENT=dbimport \
AC_UPDATES_ENABLE_DATABASES=7 \
dbimport -c "${CONF_DIR}/dbimport.conf"

echo "Database initialization/update completed."

# The dedicated dbimport process owns database migrations. Runtime services
# should never independently apply database updates.
export AC_UPDATES_ENABLE_DATABASES=0

echo "Starting AzerothCore authserver..."
ACORE_COMPONENT=authserver \
authserver -c "${CONF_DIR}/authserver.conf" </dev/null &

echo "Starting AzerothCore worldserver..."
export ACORE_COMPONENT=worldserver

exec worldserver -c "${CONF_DIR}/worldserver.conf"
