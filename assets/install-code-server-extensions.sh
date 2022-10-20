#!/usr/bin/env bash

set -e
# ---

# install Python (https://marketplace.visualstudio.com/items?itemName=ms-python.python)
/opt/vscode/bin/code-server --install-extension \
    ms-python.python

# install Terminals Manager (https://marketplace.visualstudio.com/items?itemName=fabiospampinato.vscode-terminals)
/opt/vscode/bin/code-server --install-extension \
    fabiospampinato.vscode-terminals

# ---
set +e
