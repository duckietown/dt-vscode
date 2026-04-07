#!/usr/bin/env bash

set -ex

# variables
VSCODE_TAR_NAME="UNDEFINED"

# download
if [ "${ARCH}" == 'amd64' ]; then
    VSCODE_TAR_NAME="code-server-${VSCODE_VERSION}-linux-amd64"
fi
if [ "${ARCH}" == 'arm64v8' ]; then
    VSCODE_TAR_NAME="code-server-${VSCODE_VERSION}-linux-arm64"
fi
if [ "${ARCH}" == 'arm32v7' ]; then
    VSCODE_TAR_NAME="code-server-${VSCODE_VERSION}-linux-armv7l"
fi
VSCODE_TAR_URL="https://github.com/coder/code-server/releases/download/v${VSCODE_VERSION}/${VSCODE_TAR_NAME}.tar.gz"

apt-get update && apt-get install -y curl gnupg

mkdir -p /usr/share/keyrings

curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key \
  | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg

echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_19.x focal main" \
  > /etc/apt/sources.list.d/nodesource.list

apt-get update

# install NodeJS
wget https://deb.nodesource.com/setup_20.x -O - | sudo -E bash -
apt-get install -y nodejs

# install
mkdir -p "${VSCODE_INSTALL_DIR}"
wget -qO /tmp/code-server.tar.gz "${VSCODE_TAR_URL}"
tar xf /tmp/code-server.tar.gz -C "${VSCODE_INSTALL_DIR}" --strip-components=1

# clean up
apt-get purge --auto-remove -y \
    nodejs
apt-get clean
rm -f \
    /tmp/code-server.tar.gz \
    /etc/apt/sources.list.d/nodesource.list

set +e
