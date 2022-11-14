#!/bin/bash

# force rerun of /entrypoint.sh
export DT_ENTRYPOINT_SOURCED=0
source /environment.sh

# initialize launch file
dt-launchfile-init

# YOUR CODE BELOW THIS LINE
# ----------------------------------------------------------------------------

# NOTE: Use the variable DT_REPO_PATH to know the absolute path to your code
# NOTE: Use `dt-exec COMMAND` to run the main process (blocking process)

set -e

# external variables are:
# - VSCODE_AUTH
# - VSCODE_PORT
# - SSL_CONFIG
# - VSCODE_PATH

/opt/vscode/bin/code-server \
    --auth ${VSCODE_AUTH:-none} \
    --bind-addr "0.0.0.0:${VSCODE_PORT}" \
    ${SSL_CONFIG:-} \
    "${VSCODE_PATH}"

# ----------------------------------------------------------------------------
# YOUR CODE ABOVE THIS LINE
