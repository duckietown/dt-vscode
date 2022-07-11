#!/bin/bash

source /environment.sh

# initialize launch file
dt-launchfile-init

# YOUR CODE BELOW THIS LINE
# ----------------------------------------------------------------------------

# NOTE: Use the variable DT_REPO_PATH to know the absolute path to your code
# NOTE: Use `dt-exec COMMAND` to run the main process (blocking process)

set -e

# variables
vscode_path="${USER_WS_DIR}"

# find GID of docker's group on the host
GID=$(awk -F':' '/docker/{print $3}' /host/etc/group)

# add user duckie to group docker
GNAME=docker
if [ ! "$(getent group "${GID}")" ]; then
    echo "Creating a group '${GNAME}' with GID:${GID} for the user duckie"
    # create group
    groupadd --gid ${GID} ${GNAME}
    usermod -aG ${GNAME} duckie
else
    GROUP_STR=$(getent group ${GID})
    readarray -d : -t strarr <<< "$GROUP_STR"
    GNAME="${strarr[0]}"
    echo "A group with GID:${GID} (i.e., ${GNAME}) already exists. Reusing it."
fi

# look for workspaces, auto-open if only one is available
code_wss=$(find "${USER_WS_DIR}" -type f -iname "*.code-workspace")
code_wss_num=$(echo "${code_wss}" | wc -l)

if [ "${code_wss_num}" = "1" ]; then
    echo "Found only 1 workspace at '${code_wss}', auto-opening..."
    vscode_path="${code_wss}"
fi

set +e

# launching app (retry 20 times, wait 5 seconds between trials)
sleep 5
max_trials=20
for (( trial=1; trial<=$max_trials; trial++ )); do
    echo "Launching VSCode, trial ${trial}/${max_trials}..."
    sudo \
        -H \
        -u duckie \
        /opt/vscode/bin/code-server \
            --auth none \
            --bind-addr "0.0.0.0:${VSCODE_PORT}" \
            "${vscode_path}"
    # exit code 0 means requested shutdown
    if [ "$?" -eq 0 ]; then
        exit 0
    fi
    sleep 5
done
echo "All ${max_trials} attempts at running VSCode failed. Giving up!"

# ----------------------------------------------------------------------------
# YOUR CODE ABOVE THIS LINE
