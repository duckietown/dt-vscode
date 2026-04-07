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


# install NodeJS


NODE_VERSION=${1:-20}  # default to Node 20 if not specified

echo "Installing Node.js version $NODE_VERSION..."

# Install dependencies for NodeSource
apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add NodeSource GPG key
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg

# Add NodeSource repository
DISTRO="$(lsb_release -s -c)"
echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x $DISTRO main" \
    > /etc/apt/sources.list.d/nodesource.list

# Update and install Node.js
apt-get update && apt-get install -y nodejs

# Verify installation
echo "Node.js version: $(node -v)"
echo "NPM version: $(npm -v)"

echo "Node.js $NODE_VERSION installed successfully!"

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
