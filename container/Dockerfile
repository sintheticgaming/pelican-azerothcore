# SPDX-License-Identifier: GPL-2.0-or-later

ARG ACORE_AUTHSERVER_IMAGE=acore/ac-wotlk-authserver:master
ARG ACORE_DBIMPORT_IMAGE=acore/ac-wotlk-db-import:master
ARG ACORE_WORLDSERVER_IMAGE=acore/ac-wotlk-worldserver:master

FROM ${ACORE_AUTHSERVER_IMAGE} AS upstream-auth
FROM ${ACORE_DBIMPORT_IMAGE} AS upstream-dbimport

FROM ${ACORE_WORLDSERVER_IMAGE}

LABEL org.opencontainers.image.title="pelican-azerothcore"
LABEL org.opencontainers.image.description="Pelican-compatible runtime for AzerothCore"
LABEL org.opencontainers.image.source="https://github.com/sintheticgaming/pelican-azerothcore"
LABEL org.opencontainers.image.licenses="GPL-2.0-or-later"

USER root

COPY --from=upstream-auth \
    /azerothcore/env/dist/bin/authserver \
    /azerothcore/env/dist/bin/authserver

COPY --from=upstream-dbimport \
    /azerothcore/env/dist/bin/dbimport \
    /azerothcore/env/dist/bin/dbimport

COPY --from=upstream-dbimport \
    /azerothcore/data \
    /azerothcore/data

COPY --from=upstream-dbimport \
    /azerothcore/modules \
    /azerothcore/modules

COPY --chown=acore:acore --chmod=755 \
    container/entrypoint.sh \
    /azerothcore/pelican-entrypoint.sh

COPY --chown=acore:acore --chmod=755 \
    container/start.sh \
    /azerothcore/pelican-start.sh

USER acore

ENTRYPOINT ["/usr/bin/env", "bash", "/azerothcore/pelican-entrypoint.sh"]
CMD ["/azerothcore/pelican-start.sh"]
