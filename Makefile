all: 

NODE6_VERSION = $(shell curl -qs https://deb.nodesource.com/node_6.x/dists/stretch/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
NODE8_VERSION = $(shell curl -qs https://deb.nodesource.com/node_8.x/dists/stretch/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
YARN_VERSION = $(shell curl -qs http://dl.yarnpkg.com/debian/dists/stable/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
GOSS_VERSION := 0.3.5

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

bin/goss:
	mkdir -p bin
	curl -o bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss

test-6: bin/goss
	@docker run -d -t --name $@ bearstech/node-dev:6 > /dev/null
	@docker cp tests $@:/goss
	@docker cp bin/goss $@:/usr/local/bin/goss
	@docker exec -t -w /goss $@ goss -g node-dev.yaml --vars vars/6.yaml validate --max-concurrent 1 --format documentation
	@docker stop $@ > /dev/null
	@docker rm $@ > /dev/null

test-8: bin/goss
	@docker run -d -t --name $@ bearstech/node-dev:8 > /dev/null
	@docker cp tests $@:/goss
	@docker cp bin/goss $@:/usr/local/bin/goss
	@docker exec -t -w /goss $@ goss -g node-dev.yaml --vars vars/8.yaml validate --max-concurrent 1 --format documentation
	@docker stop $@ > /dev/null
	@docker rm $@ > /dev/null

tests: test-6 test-8
