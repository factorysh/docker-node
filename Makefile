all: 

NODE6_VERSION = $(shell curl -qs https://deb.nodesource.com/node_6.x/dists/stretch/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
NODE8_VERSION = $(shell curl -qs https://deb.nodesource.com/node_8.x/dists/stretch/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
YARN_VERSION = $(shell curl -qs http://dl.yarnpkg.com/debian/dists/stable/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)

pull:
	docker pull bearstech/debian:stretch

build: node node-dev node8 node8-dev

push:
	docker push bearstech/node:6
	docker push bearstech/node:lts
	docker push bearstech/node-dev:lts
	docker push bearstech/node-dev:6
	docker push bearstech/node:8
	docker push bearstech/node-dev:8

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
	docker build -t bearstech/node-dev:6 \
		--build-arg NODE_MAJOR_VERSION=6 \
		--build-arg YARN_VERSION=${YARN_VERSION} \
		-f Dockerfile.dev .
	docker tag bearstech/node-dev:6 bearstech/node-dev:lts

node8-dev:
	docker build -t bearstech/node-dev:8 \
		--build-arg NODE_MAJOR_VERSION=8 \
		--build-arg YARN_VERSION=${YARN_VERSION} \
		-f Dockerfile.dev .

tests:
	echo "No tests provided for docker-node..."