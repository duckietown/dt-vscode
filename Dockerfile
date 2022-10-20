# parameters
ARG REPO_NAME="dt-vscode"
ARG DESCRIPTION="VSCode back-end"
ARG MAINTAINER="Andrea F. Daniele (afdaniele@ttic.edu)"
# pick an icon from: https://fontawesome.com/v4.7.0/icons/
ARG ICON="code"

# ==================================================>
# ==> Do not change the code below this line
ARG ARCH
ARG DISTRO=daffy
ARG DOCKER_REGISTRY=docker.io
ARG BASE_IMAGE=dt-commons
ARG BASE_TAG=${DISTRO}-${ARCH}
ARG LAUNCHER=default

# define base image
FROM ${DOCKER_REGISTRY}/duckietown/${BASE_IMAGE}:${BASE_TAG} as BASE

# recall all arguments
ARG ARCH
ARG DISTRO
ARG REPO_NAME
ARG DESCRIPTION
ARG MAINTAINER
ARG ICON
ARG BASE_TAG
ARG BASE_IMAGE
ARG LAUNCHER
# - buildkit
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

# check build arguments
RUN dt-build-env-check "${REPO_NAME}" "${MAINTAINER}" "${DESCRIPTION}"

# define/create repository path
ARG REPO_PATH="${SOURCE_DIR}/${REPO_NAME}"
ARG LAUNCH_PATH="${LAUNCH_DIR}/${REPO_NAME}"
RUN mkdir -p "${REPO_PATH}" "${LAUNCH_PATH}"
WORKDIR "${REPO_PATH}"

# keep some arguments as environment variables
ENV DT_MODULE_TYPE="${REPO_NAME}" \
    DT_MODULE_DESCRIPTION="${DESCRIPTION}" \
    DT_MODULE_ICON="${ICON}" \
    DT_MAINTAINER="${MAINTAINER}" \
    DT_REPO_PATH="${REPO_PATH}" \
    DT_LAUNCH_PATH="${LAUNCH_PATH}" \
    DT_LAUNCHER="${LAUNCHER}"

# install apt dependencies
COPY ./dependencies-apt.txt "${REPO_PATH}/"
RUN dt-apt-install ${REPO_PATH}/dependencies-apt.txt

# install python3 dependencies
ARG PIP_INDEX_URL="https://pypi.org/simple"
ENV PIP_INDEX_URL=${PIP_INDEX_URL}
COPY ./dependencies-py3.* "${REPO_PATH}/"
RUN python3 -m pip install -r ${REPO_PATH}/dependencies-py3.txt

# copy the source code
COPY ./packages "${REPO_PATH}/packages"

# install launcher scripts
COPY ./launchers/. "${LAUNCH_PATH}/"
RUN dt-install-launchers "${LAUNCH_PATH}"

# define default command
CMD ["bash", "-c", "dt-launcher-${DT_LAUNCHER}"]

# store module metadata
LABEL org.duckietown.label.module.type="${REPO_NAME}" \
    org.duckietown.label.module.description="${DESCRIPTION}" \
    org.duckietown.label.module.icon="${ICON}" \
    org.duckietown.label.platform.os="${TARGETOS}" \
    org.duckietown.label.platform.architecture="${TARGETARCH}" \
    org.duckietown.label.platform.variant="${TARGETVARIANT}" \
    org.duckietown.label.code.location="${REPO_PATH}" \
    org.duckietown.label.code.version.distro="${DISTRO}" \
    org.duckietown.label.base.image="${BASE_IMAGE}" \
    org.duckietown.label.base.tag="${BASE_TAG}" \
    org.duckietown.label.maintainer="${MAINTAINER}"
# <== Do not change the code above this line
# <==================================================

# install VSCode
ENV VSCODE_VERSION="4.7.1" \
    VSCODE_INSTALL_DIR="/opt/vscode" \
    VSCODE_PORT="8088" \
    VSCODE_USER_SETTINGS_DIR="/home/duckie/.local/share/code-server/User" \
    VSCODE_USER_EXTENSIONS_DIR="/home/duckie/.local/share/code-server/extensions"

COPY ./assets/install-code-server.sh /tmp/install-code-server.sh
RUN /tmp/install-code-server.sh && \
    rm -f install-code-server.sh

# copy settings/keybindings file
ADD --chown=duckie:duckie \
    ./assets/settings.json "${VSCODE_USER_SETTINGS_DIR}/settings.json"
ADD --chown=duckie:duckie \
    ./assets/keybindings.json "${VSCODE_USER_SETTINGS_DIR}/keybindings.json"

# install VSCode extensions
USER duckie
COPY ./assets/install-code-server-extension.sh /tmp/install-code-server-extension

# install Python (https://marketplace.visualstudio.com/items?itemName=ms-python.python)
RUN /tmp/install-code-server-extension ms-python.python 2022.16.1

# install Terminals Manager (https://marketplace.visualstudio.com/items?itemName=fabiospampinato.vscode-terminals)
RUN /tmp/install-code-server-extension fabiospampinato.vscode-terminals 1.13.0

USER root

# install Docker CLI
ENV DOCKER_CLI_VERSION="20.10.12"
COPY assets/install-docker-cli.sh /tmp/install-docker-cli.sh
RUN /tmp/install-docker-cli.sh && \
    rm /tmp/install-docker-cli.sh
