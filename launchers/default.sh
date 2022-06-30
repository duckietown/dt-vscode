#!/bin/bash

source /environment.sh

# initialize launch file
dt-launchfile-init

# YOUR CODE BELOW THIS LINE
# ----------------------------------------------------------------------------


# NOTE: Use the variable DT_REPO_PATH to know the absolute path to your code
# NOTE: Use `dt-exec COMMAND` to run the main process (blocking process)

# launching app
dt-exec \
    sudo \
        -H \
        -u duckie \
        /opt/vscode/bin/code-server \
            --auth none \
            --bind-addr "0.0.0.0:${VSCODE_PORT}" \
            "${USER_WS_DIR}"

# ----------------------------------------------------------------------------
# YOUR CODE ABOVE THIS LINE

# wait for app to end
dt-launchfile-join
