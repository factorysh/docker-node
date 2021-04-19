
include Makefile.lint
include Makefile.build_args

DEBIAN_VERSION = buster

NODE10_VERSION = $(shell curl -qs https://deb.nodesource.com/node_10.x/dists/stretch/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
NODE12_VERSION = $(shell curl -qs https://deb.nodesource.com/node_12.x/dists/stretch/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
NODE14_VERSION = $(shell curl -qs https://deb.nodesource.com/node_14.x/dists/stretch/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
YARN_VERSION = $(shell curl -qs http://dl.yarnpkg.com/debian/dists/stable/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
GOSS_VERSION := 0.3.16

all: | pull build tests

pull:
	docker pull bearstech/debian:$(DEBIAN_VERSION)

build: \
			node10 node10-dev \
			node12 node12-dev \
			node14 node14-dev

push:
	docker push bearstech/node:10
	docker push bearstech/node-dev:10
	docker push bearstech/node:12
	docker push bearstech/node-dev:12
	docker push bearstech/node:14
	docker push bearstech/node-dev:14
	docker push bearstech/node:lts
	docker push bearstech/node-dev:lts

remove_image:
	docker rmi bearstech/node:10
	docker rmi bearstech/node-dev:10
	docker rmi bearstech/node:12
	docker rmi bearstech/node-dev:12
	docker rmi bearstech/node:14
	docker rmi bearstech/node-dev:14
	docker rmi bearstech/node:lts
	docker rmi bearstech/node-dev:lts

node10:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg DEBIAN_VERSION=$(DEBIAN_VERSION) \
		--build-arg NODE_VERSION=${NODE10_VERSION} \
		--build-arg NODE_MAJOR_VERSION=10 \
		-t bearstech/node:10 .

node12:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg DEBIAN_VERSION=$(DEBIAN_VERSION) \
		--build-arg NODE_VERSION=${NODE12_VERSION} \
		--build-arg NODE_MAJOR_VERSION=12 \
		-t bearstech/node:12 .

node14:
	docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg DEBIAN_VERSION=buster \
		--build-arg NODE_VERSION=${NODE14_VERSION} \
		--build-arg NODE_MAJOR_VERSION=14 \
		-t bearstech/node:14 .
	docker tag bearstech/node:14 bearstech/node:lts

node10-dev:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg DEBIAN_VERSION=$(DEBIAN_VERSION) \
		--build-arg NODE_VERSION=${NODE10_VERSION} \
		--build-arg NODE_MAJOR_VERSION=10 \
		--build-arg YARN_VERSION=${YARN_VERSION} \
		-t bearstech/node-dev:10 \
		-f Dockerfile.dev .

node12-dev:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg DEBIAN_VERSION=$(DEBIAN_VERSION) \
		--build-arg NODE_VERSION=${NODE12_VERSION} \
		--build-arg NODE_MAJOR_VERSION=12 \
		--build-arg YARN_VERSION=${YARN_VERSION} \
		-t bearstech/node-dev:12 \
		-f Dockerfile.dev .

node14-dev:
	docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg DEBIAN_VERSION=buster \
		--build-arg NODE_VERSION=${NODE14_VERSION} \
		--build-arg NODE_MAJOR_VERSION=14 \
		--build-arg YARN_VERSION=${YARN_VERSION} \
		-t bearstech/node-dev:14 \
		-f Dockerfile.dev .
	docker tag bearstech/node-dev:14 bearstech/node-dev:lts


bin/goss:
	mkdir -p bin
	curl -o bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss

NAME_CONTAINER := ""
CMD_CONTAINER := ""
IMG_CONTAINER := ""

test-deployed:
	@test "${NAME_CONTAINER}" || (echo "you cannot call this rule..." && exit 1)
	@test "${CMD_CONTAINER}" || (echo "you cannot call this rule..." && exit 1)
	@test "${IMG_CONTAINER}" || (echo "you cannot call this rule..." && exit 1)
	@(docker stop ${NAME_CONTAINER} > /dev/null 2>&1 && docker rm ${NAME_CONTAINER} > /dev/null 2>&1) || true
	@docker run -d -t --name ${NAME_CONTAINER} ${IMG_CONTAINER} > /dev/null
	@docker cp tests_node/. ${NAME_CONTAINER}:/goss
	@docker cp bin/goss ${NAME_CONTAINER}:/usr/local/bin/goss
	@docker exec -t -w /goss ${NAME_CONTAINER} ${CMD_CONTAINER}
	@docker stop ${NAME_CONTAINER} > /dev/null
	@docker rm ${NAME_CONTAINER} > /dev/null

test-10: bin/goss
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:10" \
			CMD_CONTAINER="goss -g node-dev.yaml --vars vars/10.yaml validate --max-concurrent 4 --format documentation"
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:10" \
			CMD_CONTAINER="goss -g node-dev-npm.yaml --vars vars/10.yaml validate --max-concurrent 4 --format documentation"
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:10" \
			CMD_CONTAINER="goss -g node-dev-yarn.yaml --vars vars/10.yaml validate --max-concurrent 4 --format documentation"

test-12: bin/goss
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:12" \
			CMD_CONTAINER="goss -g node-dev.yaml --vars vars/12.yaml validate --max-concurrent 4 --format documentation"
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:12" \
			CMD_CONTAINER="goss -g node-dev-npm.yaml --vars vars/12.yaml validate --max-concurrent 4 --format documentation"
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:12" \
			CMD_CONTAINER="goss -g node-dev-yarn.yaml --vars vars/12.yaml validate --max-concurrent 4 --format documentation"

test-14: bin/goss
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:14" \
			CMD_CONTAINER="goss -g node-dev.yaml --vars vars/14.yaml validate --max-concurrent 4 --format documentation"
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:14" \
			CMD_CONTAINER="goss -g node-dev-npm.yaml --vars vars/14.yaml validate --max-concurrent 4 --format documentation"
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:14" \
			CMD_CONTAINER="goss -g node-dev-yarn.yaml --vars vars/14.yaml validate --max-concurrent 4 --format documentation"

down:

tests: test-10 test-12 test-14
