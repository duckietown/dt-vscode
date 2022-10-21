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

# look for SSL keys
if [ -f /ssl/localhost.pem ] & [ -f /ssl/localhost-key.pem ]; then
    echo "GOOD: Found SSL keys under '/ssl', using HTTPS"
    cp -R /ssl /tmp/ssl
    chown -R duckie:duckie /tmp/ssl
    SSL_CONFIG="--cert /tmp/ssl/localhost.pem --cert-key /tmp/ssl/localhost-key.pem"
else
    echo "WARNING: No SSL keys found under '/ssl', using HTTP instead"
    SSL_CONFIG=""
fi

set +e

# launching app (retry until it succeeds, wait 5 seconds between trials)
sleep 5
trial=1
while true; do
    echo "Launching VSCode, trial ${trial}..."
    set -x
    sudo \
        -H \
        -u duckie \
        /opt/vscode/bin/code-server \
            --auth none \
            --bind-addr "0.0.0.0:${VSCODE_PORT}" \
            ${SSL_CONFIG} \
            "${vscode_path}"
    set +x
    # exit code 0 means requested shutdown
    if [ "$?" -eq 0 ]; then
        exit 0
    fi
    sleep 5
    trial=$((trial+1))
done

# ----------------------------------------------------------------------------
# YOUR CODE ABOVE THIS LINE
