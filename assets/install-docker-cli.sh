#!/usr/bin/env bash

set -e

# variables
DOCKER_CLI_TAR_NAME="UNDEFINED"

# download
if [ "${ARCH}" == 'amd64' ]; then
    DOCKER_CLI_TAR_NAME="x86_64/docker"
fi
if [ "${ARCH}" == 'arm64v8' ]; then
    DOCKER_CLI_TAR_NAME="aarch64/docker"
fi
if [ "${ARCH}" == 'arm32v7' ]; then
    DOCKER_CLI_TAR_NAME="armhf/docker"
fi
DOCKER_CLI_TAR_URL="https://download.docker.com/linux/static/stable/${DOCKER_CLI_TAR_NAME}-${DOCKER_CLI_VERSION}.tgz"

# install docker CLI
wget -qO /tmp/docker-cli.tgz "${DOCKER_CLI_TAR_URL}"
tar xzvf /tmp/docker-cli.tgz \
    --strip 1 \
    -C /usr/local/bin docker/docker
rm /tmp/docker-cli.tgz

set +e
