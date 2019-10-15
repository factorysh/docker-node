
include Makefile.build_args

NODE6_VERSION = $(shell curl -qs https://deb.nodesource.com/node_6.x/dists/stretch/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
NODE8_VERSION = $(shell curl -qs https://deb.nodesource.com/node_8.x/dists/stretch/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
NODE10_VERSION = $(shell curl -qs https://deb.nodesource.com/node_10.x/dists/stretch/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
NODE12_VERSION = $(shell curl -qs https://deb.nodesource.com/node_12.x/dists/stretch/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
YARN_VERSION = $(shell curl -qs http://dl.yarnpkg.com/debian/dists/stable/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
GOSS_VERSION := 0.3.6

all: | pull build tests

pull:
	docker pull bearstech/debian:stretch

build: \
			node6 node6-dev \
			node8 node8-dev \
			node10 node10-dev \
			node12 node12-dev

push:
	docker push bearstech/node:6
	docker push bearstech/node:lts
	docker push bearstech/node-dev:6
	docker push bearstech/node-dev:lts
	docker push bearstech/node:8
	docker push bearstech/node-dev:8
	docker push bearstech/node:10
	docker push bearstech/node-dev:10
	docker push bearstech/node:12
	docker push bearstech/node-dev:12

remove_image:
	docker rmi bearstech/node:6
	docker rmi bearstech/node:lts
	docker rmi bearstech/node-dev:6
	docker rmi bearstech/node-dev:lts
	docker rmi bearstech/node:8
	docker rmi bearstech/node-dev:8
	docker rmi bearstech/node:10
	docker rmi bearstech/node-dev:10
	docker rmi bearstech/node:12
	docker rmi bearstech/node-dev:12

node6:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg NODE_VERSION=${NODE6_VERSION} \
		--build-arg NODE_MAJOR_VERSION=6 \
		-t bearstech/node:6 .
	docker tag bearstech/node:6 bearstech/node:lts

node8:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg NODE_VERSION=${NODE8_VERSION} \
		--build-arg NODE_MAJOR_VERSION=8 \
		-t bearstech/node:8 .

node10:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg NODE_VERSION=${NODE10_VERSION} \
		--build-arg NODE_MAJOR_VERSION=10 \
		-t bearstech/node:10 .

node12:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg NODE_VERSION=${NODE12_VERSION} \
		--build-arg NODE_MAJOR_VERSION=12 \
		-t bearstech/node:12 .

node6-dev:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/node-dev:6 \
		--build-arg NODE_VERSION=${NODE6_VERSION} \
		--build-arg NODE_MAJOR_VERSION=6 \
		--build-arg YARN_VERSION=${YARN_VERSION} \
		-f Dockerfile.dev .
	docker tag bearstech/node-dev:6 bearstech/node-dev:lts

node8-dev:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/node-dev:8 \
		--build-arg NODE_VERSION=${NODE8_VERSION} \
		--build-arg NODE_MAJOR_VERSION=8 \
		--build-arg YARN_VERSION=${YARN_VERSION} \
		-f Dockerfile.dev .

node10-dev:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/node-dev:10 \
		--build-arg NODE_VERSION=${NODE10_VERSION} \
		--build-arg NODE_MAJOR_VERSION=10 \
		--build-arg YARN_VERSION=${YARN_VERSION} \
		-f Dockerfile.dev .

node12-dev:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		-t bearstech/node-dev:12 \
		--build-arg NODE_VERSION=${NODE12_VERSION} \
		--build-arg NODE_MAJOR_VERSION=12 \
		--build-arg YARN_VERSION=${YARN_VERSION} \
		-f Dockerfile.dev .

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

test-6: bin/goss
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:6" \
			CMD_CONTAINER="goss -g node-dev.yaml --vars vars/6.yaml validate --max-concurrent 4 --format documentation"
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:6" \
			CMD_CONTAINER="goss -g node-dev-npm.yaml --vars vars/6.yaml validate --max-concurrent 4 --format documentation"
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:6" \
			CMD_CONTAINER="goss -g node-dev-yarn.yaml --vars vars/6.yaml validate --max-concurrent 4 --format documentation"

test-8: bin/goss
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:8" \
			CMD_CONTAINER="goss -g node-dev.yaml --vars vars/8.yaml validate --max-concurrent 4 --format documentation"
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:8" \
			CMD_CONTAINER="goss -g node-dev-npm.yaml --vars vars/8.yaml validate --max-concurrent 4 --format documentation"
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:8" \
			CMD_CONTAINER="goss -g node-dev-yarn.yaml --vars vars/8.yaml validate --max-concurrent 4 --format documentation"

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

down:

tests: test-6 test-8 test-10 test-12
