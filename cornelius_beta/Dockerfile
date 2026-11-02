# Cornelius pour Home Assistant : serveur Node et perception Python, sur l'image Debian de
# Home Assistant (onnxruntime et OpenCV demandent la glibc). Le miroir s'affiche sur un autre
# appareil. Cornelius, ses modules, Node, uv, Python et les images de base sont épinglés par
# commit, version ou empreinte ; les dépendances Python le sont par version.

# Image de base de Home Assistant. Elle ne s'appelle pas BUILD_FROM : les Supervisor d'avant
# 2026.04 imposaient sous ce nom une image Alpine. Un ARG utilisé par FROM se déclare avant le
# premier FROM.
ARG BASE_IMAGE=ghcr.io/home-assistant/base-debian:trixie-2026.10.3@sha256:a9fb29d0ffab1a81d6379e6252db21e0edbd1263c94d9de2cfc54a396aad8611

# Node 24 de l'image officielle, à jour des correctifs de sécurité.
FROM node:24.22.2-trixie-slim@sha256:54f84b4cf8432b21aaffd5d3ce8d41e12cea0d10d33c09d2f3c9879d49d6b446 AS node
# uv installe un Python 3.12 autonome, la version validée pour la perception (Debian 13
# fournit la 3.13).
FROM ghcr.io/astral-sh/uv:0.13.6@sha256:af22a52f5eafef3d78e551599d405c02df61919d18028f0cea8eda93bc9986d0 AS uv

FROM ${BASE_IMAGE}

ARG PYTHON_VERSION=3.12.16

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

# Commits exacts de Cornelius et de ses modules externes, propres à chaque canal (stable ou
# bêta) : scripts/bump.sh les change avec la version de l'application et son CHANGELOG.
COPY source.env /etc/cornelius-source.env

# Sources à un commit précis, vérifié ; git ne reste pas dans l'image.
RUN . /etc/cornelius-source.env \
  && apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates git \
  && fetch() { \
       git init -q "$3" \
       && git -C "$3" fetch -q --depth 1 "$1" "$2" \
       && git -C "$3" checkout -q --detach FETCH_HEAD \
       && test "$(git -C "$3" rev-parse HEAD)" = "$2" \
       && rm -rf "$3/.git"; \
     } \
  && fetch https://github.com/lfpoulain/Cornelius.git "${CORNELIUS_COMMIT}" /app \
  && fetch https://github.com/lfpoulain/cornelius-modules.git "${CORNELIUS_MODULES_COMMIT}" /opt/cornelius-modules \
  && apt-get purge -y git \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /app

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
  && node --version && npm --version

# tsx sert au démarrage : les dépendances de développement restent.
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
RUN npm ci --no-audit --no-fund \
  && npm run build \
  && npm cache clean --force \
  && rm -rf /root/.npm /tmp/*

# Perception : mêmes étapes que l'installateur Linux, sur le processeur. Le modèle de vision
# n'est pas inclus : l'administration le télécharge à la demande, dans /data.
COPY --from=uv /uv /usr/local/bin/uv
ENV UV_PYTHON_INSTALL_DIR=/opt/python \
    UV_NO_CACHE=1
RUN uv python install "${PYTHON_VERSION}" \
  && uv venv --seed --python "${PYTHON_VERSION}" .venv \
  && pip() { .venv/bin/python -m pip install --no-cache-dir --disable-pip-version-check "$@"; } \
  && pip -r perception/requirements.txt \
  && pip -r perception/requirements-wake.txt \
  && pip --no-deps openwakeword==0.6.0 \
  && .venv/bin/python perception/install_wake_features.py \
  && .venv/bin/python perception/download_models.py --no-vision \
  && rm -rf /root/.cache

# Tout ce qui doit durer vit dans /data. Les modèles de l'image y sont recopiés à chaque
# démarrage ; data/ (images générées) pointe aussi vers /data.
RUN mv models /opt/cornelius-models \
  && ln -s /data/models models \
  && ln -s /data data

# CORNELIUS_TRUST_LOOPBACK=0 : sur le réseau de l'hôte, 127.0.0.1 est partagé avec Home
# Assistant et les autres applications ; aucune ne doit compter comme l'ordinateur du miroir.
ENV CORNELIUS_SUPERVISED=1 \
    CORNELIUS_TRUST_LOOPBACK=0 \
    CORNELIUS_DATABASE=/data/cornelius.sqlite \
    CORNELIUS_MODULES_DIR=/opt/cornelius-modules

COPY rootfs /
# Les fichiers copiés depuis Windows ou par Samba perdent le bit d'exécution.
RUN chmod a+x /etc/s6-overlay/s6-rc.d/*/run /etc/s6-overlay/s6-rc.d/*/finish

LABEL org.opencontainers.image.title="Cornelius" \
      org.opencontainers.image.description="Le miroir intelligent de la famille, sur Home Assistant" \
      org.opencontainers.image.source="https://github.com/lfpoulain/cornelius-ha" \
      org.opencontainers.image.licenses="PolyForm-Noncommercial-1.0.0 AND MIT"
