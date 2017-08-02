all: node node-dev

node:
	docker build -t bearstech/node:6 .
	docker tag bearstech/node:6 bearstech/node:lts

node-dev:
	docker build -t bearstech/node-dev:6 -f Dockerfile.dev .
	docker tag bearstech/node-dev:6 bearstech/node-dev:lts

pull:
	docker pull bearstech/debian:stretch

push:
	docker push bearstech/node:6
	docker push bearstech/node:lts
