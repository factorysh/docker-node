
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
	@echo NODE10_VERSION: $(NODE10_VERSION)
	@echo NODE12_VERSION: $(NODE12_VERSION)
	@echo NODE14_VERSION: $(NODE14_VERSION)
	@echo NODE16_VERSION: $(NODE16_VERSION)
	@echo YARN_VERSION: $(YARN_VERSION)

pull:
	docker pull bearstech/debian:$(DEBIAN_VERSION)

build10: node-$(NODE10_VERSION) node_dev-$(NODE10_VERSION)
build12: node-$(NODE12_VERSION) node_dev-$(NODE12_VERSION)
build14: node-$(NODE14_VERSION) node_dev-$(NODE14_VERSION)
build16: node-$(NODE16_VERSION) node_dev-$(NODE16_VERSION)

build: variables build12 build14 build16
	docker tag bearstech/node:16 bearstech/node:lts
	docker tag bearstech/node-dev:16 bearstech/node-dev:lts

push-%:
	$(eval version=$(shell echo $@ | cut -d- -f2))
	docker push bearstech/node:$(version)
	docker push bearstech/node-dev:$(version)

push: push-12 push-14 push-16 push-lts

remove_image:
	docker rmi -f $(shell docker images -q --filter="reference=bearstech/node-dev") || true
	docker rmi -f $(shell docker images -q --filter="reference=bearstech/node") || true

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
		-t bearstech/node-dev:$(major_version) \
		-f Dockerfile.dev .

bin/goss:
	mkdir -p bin
	curl -o bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss

test-%: bin/goss
	$(eval version=$(shell echo $@ | cut -d- -f2))
	mkdir -p build
	for filename in node-dev.yaml node-dev-npm.yaml node-dev-yarn.yaml; do \
		echo $$filename $(version); \
		cp -r tests_node/ build/$(version); \
		docker run --rm -t \
			-v`pwd`/bin/goss:/usr/local/bin/goss \
			-v`pwd`/build/$(version):/goss \
			-w /goss \
			bearstech/node-dev:$(version) \
			goss -g $$filename --vars vars/$(version).yaml \
				validate --max-concurrent 4 --format documentation; \
	done

down:

tests: test-12 test-14 test-16
