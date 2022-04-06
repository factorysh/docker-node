
include Makefile.lint
include Makefile.build_args

DEBIAN_VERSION = bullseye

NODE10_VERSION = $(shell curl -qs https://deb.nodesource.com/node_10.x/dists/$(DEBIAN_VERSION)/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
NODE12_VERSION = $(shell curl -qs https://deb.nodesource.com/node_12.x/dists/$(DEBIAN_VERSION)/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
NODE14_VERSION = $(shell curl -qs https://deb.nodesource.com/node_14.x/dists/$(DEBIAN_VERSION)/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
NODE16_VERSION = $(shell curl -qs https://deb.nodesource.com/node_16.x/dists/$(DEBIAN_VERSION)/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
YARN_VERSION = $(shell curl -qs http://dl.yarnpkg.com/debian/dists/stable/main/binary-amd64/Packages | grep -m 1 Version: | cut -d " " -f 2 -)
GOSS_VERSION := 0.3.16

all: | pull build tests

variables:
	echo NODE10_VERSION: $(NODE10_VERSION)
	echo NODE12_VERSION: $(NODE12_VERSION)
	echo NODE14_VERSION: $(NODE14_VERSION)
	echo NODE16_VERSION: $(NODE16_VERSION)
	echo YARN_VERSION: $(YARN_VERSION)

pull:
	docker pull bearstech/debian:$(DEBIAN_VERSION)

build10: node-$(NODE10_VERSION) node_dev-$(NODE10_VERSION)
build12: node-$(NODE12_VERSION) node_dev-$(NODE12_VERSION)
build14: node-$(NODE14_VERSION) node_dev-$(NODE14_VERSION)
build16: node-$(NODE16_VERSION) node_dev-$(NODE16_VERSION)

build: variables build10 build12 build14 build16
	docker tag bearstech/node:14 bearstech/node:lts
	docker tag bearstech/node-dev:14 bearstech/node-dev:lts

push:
	docker push bearstech/node:10
	docker push bearstech/node-dev:10
	docker push bearstech/node:12
	docker push bearstech/node-dev:12
	docker push bearstech/node:14
	docker push bearstech/node-dev:14
	docker push bearstech/node:16
	docker push bearstech/node-dev:16
	docker push bearstech/node:lts
	docker push bearstech/node-dev:lts

remove_image:
	docker rmi bearstech/node:10
	docker rmi bearstech/node-dev:10
	docker rmi bearstech/node:12
	docker rmi bearstech/node-dev:12
	docker rmi bearstech/node:14
	docker rmi bearstech/node-dev:14
	docker rmi bearstech/node:16
	docker rmi bearstech/node-dev:16
	docker rmi bearstech/node:lts
	docker rmi bearstech/node-dev:lts

node-%:
	$(eval version=$(shell echo $@ | cut -d- -f2-))
	$(eval major_version=$(shell echo $(version) | cut -d. -f1))
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg DEBIAN_VERSION=$(DEBIAN_VERSION) \
		--build-arg NODE_VERSION=$(version) \
		--build-arg NODE_MAJOR_VERSION=$(major_version) \
		-t bearstech/node:$(major_version) .

node_dev-%:
	$(eval version=$(shell echo $@ | cut -d- -f2-))
	$(eval major_version=$(shell echo $(version) | cut -d. -f1))
	docker build \
		$(DOCKER_BUILD_ARGS) \
		--build-arg DEBIAN_VERSION=$(DEBIAN_VERSION) \
		--build-arg NODE_VERSION=$(version) \
		--build-arg NODE_MAJOR_VERSION=$(major_version) \
		--build-arg YARN_VERSION=${YARN_VERSION} \
		-t bearstech/node-dev:10 \
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

test-%: bin/goss
	$(eval version=$(shell echo $@ | cut -d- -f2))
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:$(version)" \
			CMD_CONTAINER="goss -g node-dev.yaml --vars vars/$(version).yaml validate --max-concurrent 4 --format documentation"
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:$(version)" \
			CMD_CONTAINER="goss -g node-dev-npm.yaml --vars vars/$(version).yaml validate --max-concurrent 4 --format documentation"
	make -s -C . test-deployed \
			NAME_CONTAINER="$@" \
			IMG_CONTAINER="bearstech/node-dev:$(version)" \
			CMD_CONTAINER="goss -g node-dev-yarn.yaml --vars vars/$(version).yaml validate --max-concurrent 4 --format documentation"

down:

tests: test-10 test-12 test-14 test-16
