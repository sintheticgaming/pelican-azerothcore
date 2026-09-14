#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later

set -euo pipefail

CONF_DIR="${CONF_DIR:-/azerothcore/env/dist/etc}"
REF_CONF_DIR="/azerothcore/env/ref/etc"
LOGS_DIR="${LOGS_DIR:-/azerothcore/env/dist/logs}"

mkdir -p "$CONF_DIR" "$LOGS_DIR"

# Add newly provided upstream configuration templates without replacing
# files already present in persistent server storage.
cp -r --update=none "$REF_CONF_DIR"/. "$CONF_DIR"/

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

exec "$@"
