FROM bearstech/debian:stretch

ARG NODE_VERSION
LABEL com.bearstech.version.node=${NODE_VERSION}
ARG NODE_MAJOR_VERSION

RUN apt-get update && apt-get -y install \
        apt-transport-https \
	ca-certificates \
        curl \
        && \
        curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -a && \
        echo "deb https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x stretch main" > /etc/apt/sources.list.d/nodesource.list && \
        echo "deb-src https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x stretch main" >> /etc/apt/sources.list.d/nodesource.list &&\
        apt-get update && apt-get install -y nodejs && \
        rm -rf /var/lib/apt/lists/*
