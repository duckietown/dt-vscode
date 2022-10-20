#!/usr/bin/env bash

set -e
# ---

EXTENSION=$1
VERSION=$2

set -x
/opt/vscode/bin/code-server \
    --verbose \
    --install-extension \
        ${EXTENSION}@${VERSION}
set +x

if test -z "$(find "${VSCODE_USER_EXTENSIONS_DIR}" -maxdepth 1 -name "${EXTENSION}*" -print -quit)"; then
    echo "ERROR: Extension '${EXTENSION}' failed to install"
    exit 1
fi

# ---
set +e
