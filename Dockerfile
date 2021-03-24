ARG DEBIAN_VERSION
FROM bearstech/debian:${DEBIAN_VERSION}

ARG DEBIAN_VERSION
ARG NODE_VERSION
ARG NODE_MAJOR_VERSION

LABEL com.bearstech.version.node=${NODE_VERSION}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN set -eux \
    &&  if [ -n "${HTTP_PROXY:-}" ]; then export http_proxy=${HTTP_PROXY}; fi \
    &&  apt-get update \
    &&  apt-get install -y --no-install-recommends \
              apt-transport-https \
              ca-certificates \
              curl \
              gpg \
    &&  curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor > /etc/apt/trusted.gpg.d/nodesource.gpg \
    &&  echo "deb https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x ${DEBIAN_VERSION} main" > /etc/apt/sources.list.d/nodesource.list \
    &&  apt-get update \
    &&  apt-get install -y --no-install-recommends \
              nodejs \
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/*

SHELL ["/bin/sh", "-c"]

# generated labels

ARG GIT_VERSION
ARG GIT_DATE
ARG BUILD_DATE

LABEL \
    com.bearstech.image.revision_date=${GIT_DATE} \
    org.opencontainers.image.authors=Bearstech \
    org.opencontainers.image.revision=${GIT_VERSION} \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.url=https://github.com/factorysh/docker-node \
    org.opencontainers.image.source=https://github.com/factorysh/docker-node/blob/${GIT_VERSION}/Dockerfile
