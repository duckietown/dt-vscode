#!/bin/bash

source /environment.sh

# initialize launch file
dt-launchfile-init

# YOUR CODE BELOW THIS LINE
# ----------------------------------------------------------------------------

# NOTE: Use the variable DT_REPO_PATH to know the absolute path to your code
# NOTE: Use `dt-exec COMMAND` to run the main process (blocking process)

set -ex

# variables
VSCODE_AUTH=none
VSCODE_PATH=${VSCODE_PATH:-${SOURCE_DIR}}
VSCODE_USER=${DT_USER_NAME}

# look for '*.code-workspace' workspaces and count them
code_wss=$(find "${VSCODE_PATH}" -mindepth 2 -maxdepth 2 -type f -iname "*.code-workspace")
code_wss_num=$(echo "${code_wss}" | sed '/^$/d'| awk '{print NR}' | sort -nr | sed -n '1p')

# auto-open if only one is available
if [ "${code_wss}" != "" ] & [ "${code_wss_num}" = "1" ]; then
    code_ws=${code_wss}
    echo "Found only 1 workspace at '${code_ws}', auto-opening..."
    # path is now the path to the .code-workspace file
    VSCODE_PATH="${code_ws}"
else
    # look for workspaces and count them
    code_wss=$(find "${VSCODE_PATH}" -mindepth 2 -maxdepth 2 -type d -iname ".vscode")
    code_wss_num=$(echo "${code_wss}" | sed '/^$/d'| awk '{print NR}' | sort -nr | sed -n '1p')

    # auto-open if only one is available
    if [ "${code_wss}" != "" ] & [ "${code_wss_num}" = "1" ]; then
        code_ws=$(dirname "${code_wss}")
        echo "Found only 1 workspace at '${code_ws}', auto-opening..."
        # path is now the path to the directory containing the .vscode file
        VSCODE_PATH="${code_ws}"
    fi
fi

# make a new user if a HOST_UID was given
if [ "${HOST_UID:-}" != "" ]; then
    UNAME=vsuser
    if [ ! "$(getent passwd "${HOST_UID}")" ]; then
        echo "Creating a user '${UNAME}' with UID:${HOST_UID} to emulate host user"
        # create group
        addgroup \
            --gid \
            "${HOST_UID}" \
            "${UNAME}"
        # create user
        useradd \
            --create-home \
            --home-dir "/home/${UNAME}" \
            --comment "VSCode User" \
            --shell "/bin/bash" \
            --password "aa26uhROPk6sA" \
            --uid "${HOST_UID}" \
            --gid "${HOST_UID}" \
            "${UNAME}"
    else
        USER_STR=$(getent passwd ${HOST_UID})
        readarray -d : -t strarr <<< "$USER_STR"
        UNAME="${strarr[0]}"
        echo "A user with UID:${HOST_UID} (i.e., ${UNAME}) already exists. Reusing it."
    fi
    VSCODE_USER=${UNAME}
    # copy code-server configuration from the user `duckie`
    mkdir -p "/home/${UNAME}/.local/share"
    cp -r "${DT_USER_HOME}/.local/share/code-server" "/home/${UNAME}/.local/share/code-server"
    chown -R ${UNAME}:${UNAME} "/home/${UNAME}/.local"
    export VSCODE_USER_SETTINGS_DIR="/home/${UNAME}/.local/share/code-server/User"
    export VSCODE_USER_EXTENSIONS_DIR="/home/${UNAME}/.local/share/code-server/extensions"
fi

# find GID of docker's group on the host
# GID=$(awk -F':' '/docker/{print $3}' /host/etc/group)

# add user to group docker
#GNAME=docker
#if [ ! "$(getent group "${GID}")" ]; then
#    echo "Creating a group '${GNAME}' with GID:${GID} for the user '${VSCODE_USER}'"
#    # create group
#    groupadd --gid ${GID} ${GNAME}
#    usermod -aG ${GNAME} ${VSCODE_USER}
#else
#    GROUP_STR=$(getent group ${GID})
#    readarray -d : -t strarr <<< "$GROUP_STR"
#    GNAME="${strarr[0]}"
#    echo "A group with GID:${GID} (i.e., ${GNAME}) already exists. Reusing it."
#fi

# look for SSL keys
if [ -f /ssl/localhost.pem ] & [ -f /ssl/localhost-key.pem ]; then
    echo "GOOD: Found SSL keys under '/ssl', using HTTPS"
    cp -R /ssl /tmp/ssl
    chown -R ${VSCODE_USER}:${VSCODE_USER} /tmp/ssl
    SSL_CONFIG="--cert /tmp/ssl/localhost.pem --cert-key /tmp/ssl/localhost-key.pem"
else
    echo "WARNING: No SSL keys found under '/ssl', using HTTP instead"
    SSL_CONFIG=""
fi

set +e

# export configuration
export VSCODE_AUTH
export VSCODE_PORT
export SSL_CONFIG
export VSCODE_PATH

# launching app (retry until it succeeds, wait 5 seconds between trials)
echo "Launching VSCode as user '${VSCODE_USER}'..."
trial=1
while true; do
    echo "Launching VSCode, trial ${trial}..."
    set -x
    sudo \
        --set-home \
        --preserve-env \
        --user ${VSCODE_USER} \
        LD_LIBRARY_PATH=$LD_LIBRARY_PATH PYTHONPATH=$PYTHONPATH PATH=$PATH dt-launcher-code-server
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
