FROM bearstech/debian:stretch

ARG NODE_VERSION
ARG NODE_MAJOR_VERSION

LABEL com.bearstech.version.node=${NODE_VERSION}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN set -eux \
    &&  apt-get update \
    &&  apt-get install -y --no-install-recommends \
              apt-transport-https \
              ca-certificates \
              curl \
    &&  curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -a \
    &&  echo "deb https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x stretch main" > /etc/apt/sources.list.d/nodesource.list \
    &&  echo "deb-src https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x stretch main" >>  /etc/apt/sources.list.d/nodesource.list \
    &&  apt-get update \
    &&  apt-get install -y --no-install-recommends \
              nodejs \
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/*

SHELL ["/bin/sh", "-c"]
ARG GIT_VERSION
LABEL com.bearstech.source.node=https://github.com/factorysh/docker-node/commit/${GIT_VERSION}

ARG GIT_DATE
LABEL com.bearstech.date.node=${GIT_DATE}

