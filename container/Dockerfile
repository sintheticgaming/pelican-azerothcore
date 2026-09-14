# SPDX-License-Identifier: GPL-2.0-or-later

ARG ACORE_TAG=master

FROM acore/ac-wotlk-authserver:${ACORE_TAG} AS upstream-auth
FROM acore/ac-wotlk-db-import:${ACORE_TAG} AS upstream-dbimport

FROM acore/ac-wotlk-worldserver:${ACORE_TAG}

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
