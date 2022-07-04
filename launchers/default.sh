#!/bin/bash

source /environment.sh

# initialize launch file
dt-launchfile-init

# YOUR CODE BELOW THIS LINE
# ----------------------------------------------------------------------------

# NOTE: Use the variable DT_REPO_PATH to know the absolute path to your code
# NOTE: Use `dt-exec COMMAND` to run the main process (blocking process)

# launching app (retry 3 times, minimum timeout is 10secs, wait 5 seconds between trials)

max_trials=3
for (( trial=1; trial<=$max_trials; trial++ )); do
    echo "Launching VSCode, trial ${trial}/${max_trials}..."
    sudo \
        -H \
        -u duckie \
        /opt/vscode/bin/code-server \
            --auth none \
            --bind-addr "0.0.0.0:${VSCODE_PORT}" \
            "${USER_WS_DIR}"
    # exit code 0 means requested shutdown
    if [ "$?" -eq 0 ]; then
        exit 0
    fi
done
echo "All ${max_trials} attempts at running VSCode failed. Giving up!"

# ----------------------------------------------------------------------------
# YOUR CODE ABOVE THIS LINE
