#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later

set -euo pipefail

SERVER_DIR="${SERVER_DIR:-/home/container}"
CONF_DIR="${CONF_DIR:-${SERVER_DIR}/etc}"
DATA_DIR="${DATA_DIR:-${SERVER_DIR}/data}"
LOGS_DIR="${LOGS_DIR:-${SERVER_DIR}/logs}"

REF_CONF_DIR="/azerothcore/env/ref/etc"

mkdir -p "$CONF_DIR" "$DATA_DIR" "$LOGS_DIR"

# Add newly provided upstream configuration templates without replacing
# files already present in persistent server storage.
cp -r --update=none "$REF_CONF_DIR"/. "$CONF_DIR"/

# Create active core configuration files from upstream defaults when missing.
for component in authserver worldserver dbimport; do
    conf="$CONF_DIR/$component.conf"
    dist="$CONF_DIR/$component.conf.dist"

    if [[ ! -f "$conf" ]]; then
        if [[ -f "$dist" ]]; then
            cp "$dist" "$conf"
            echo "Created $conf from upstream defaults."
        else
            touch "$conf"
            echo "Created empty $conf."
        fi
    fi
done

# Create active module configuration files from newly supplied upstream
# templates without replacing existing user configuration.
if [[ -d "$CONF_DIR/modules" ]]; then
    while IFS= read -r -d '' dist; do
        conf="${dist%.dist}"

        if [[ ! -f "$conf" ]]; then
            cp "$dist" "$conf"
            echo "Created $conf from upstream module defaults."
        fi
    done < <(find "$CONF_DIR/modules" -type f -name '*.conf.dist' -print0)
fi

# Tell AzerothCore where Pelican's persistent files live.
export AC_DATA_DIR="$DATA_DIR"
export AC_LOGS_DIR="$LOGS_DIR"

exec "$@"
