all: node node-dev

NODE6_VERSION = $(shell curl -qs https://deb.nodesource.com/node_6.x/dists/stretch/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
NODE8_VERSION = $(shell curl -qs https://deb.nodesource.com/node_8.x/dists/stretch/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)

node:
	docker build \
		--build-arg NODE_VERSION=${NODE6_VERSION} \
		--build-arg NODE_MAJOR_VERSION=6 \
		-t bearstech/node:6 .
	docker tag bearstech/node:6 bearstech/node:lts

node8:
	docker build \
		--build-arg NODE_VERSION=${NODE8_VERSION} \
		--build-arg NODE_MAJOR_VERSION=8 \
		-t bearstech/node:8 .

node-dev:
	docker build -t bearstech/node-dev:6 -f Dockerfile.dev .
	docker tag bearstech/node-dev:6 bearstech/node-dev:lts

pull:
	docker pull bearstech/debian:stretch

push:
	docker push bearstech/node:6
	docker push bearstech/node:lts
	docker push bearstech/node-dev:lts
	docker push bearstech/node-dev:6
