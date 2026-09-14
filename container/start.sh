#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later

set -euo pipefail

export AC_UPDATES_ENABLE_DATABASES=0
export AC_DISABLE_INTERACTIVE=1
export AC_CLOSE_IDLE_CONNECTIONS=0

echo "Starting AzerothCore authserver..."
ACORE_COMPONENT=authserver authserver </dev/null &

echo "Starting AzerothCore worldserver..."
export ACORE_COMPONENT=worldserver

exec worldserver
