FROM bearstech/debian:stretch

RUN apt-get update && apt-get -y install \
        apt-transport-https \
	ca-certificates \
        curl \
        && \
        curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -a && \
        echo 'deb https://deb.nodesource.com/node_6.x stretch main' > /etc/apt/sources.list.d/nodesource.list && \
        echo 'deb-src https://deb.nodesource.com/node_6.x stretch main' >> /etc/apt/sources.list.d/nodesource.list &&\
        apt-get update && apt-get install -y nodejs && \
        rm -rf /var/lib/apt/lists/*
