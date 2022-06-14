#!/usr/bin/env bash

set -ex

# copy code
mkdir -p "${VSCODE_BACKEND_DIR}"
cp -r ./packages/vscode-backend/* "${VSCODE_BACKEND_DIR}"

set +ex
