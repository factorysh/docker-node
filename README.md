Node docker images by bearstech
==================================

Variants of Node from Debian Buster :

- [bearstech/node-dev](https://hub.docker.com/r/bearstech/node-dev/)
- [bearstech/node](https://hub.docker.com/r/bearstech/node/)

All variants are available as tag for Node 10 12 14 lts

Dockerfiles
-----------

Dockerfiles are available at https://github.com/factorysh/docker-node

Usage
-----

```
docker run --rm bearstech/node:lts
docker run --rm bearstech/node-dev:lts
```

Yarn
----

[Yarn cache](https://classic.yarnpkg.com/en/docs/cli/cache/) serve as a local global cache package for the entire system.

Default cache directory is set to `/usr/local/share/.cache/yarn`
