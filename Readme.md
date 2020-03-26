# A Docker Image for Dreamcast Development

[![](https://images.microbadger.com/badges/image/haydenkow/nu_dckos-beta.svg)](https://microbadger.com/images/haydenkow/nu_dckos-beta)
[![](https://img.shields.io/docker/pulls/haydenkow/nu_dckos-beta.svg?cacheSeconds=3600)](https://hub.docker.com/r/haydenkow/nu_dckos-beta/)

Cross-compile your Dreamcast homebrew projects inside a Docker container.

## Changes
- gcc 7.1.0 and no C++ support above c++03
- not recommended for those looking to use C++ in any fashion, but great for C

## Quick Start

Run this command in your project's root folder to build it inside a Docker container:

```bash
docker run --rm -v "$PWD:/$PWD" -u `id -u`:`id -g` -w "$PWD" haydenkow/nu_dckos-beta make
```

This will mount the current folder to your current folder  in the container and then run `make` . You may execute other commands, of course.

Omit the command to get a login shell (`/bin/bash`) in the running container:

```bash
docker run -it --rm -v "$PWD:/$PWD" -u `id -u`:`id -g` -w "$PWD" haydenkow/nu_dckos-beta bash
```

## Continuous Integration

With the Docker image in hand, you can also build and test your Dreamcast applications on CI platforms. Here's an example configuration for Travis CI:

```yaml
# .travis.yml
language: c

sudo: required

services:
  - docker

script: docker run  --rm -v "${PWD}:/src" haydenkow/nu_dckos-beta make test
```
