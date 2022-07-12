# parameters
ARG REPO_NAME="dt-vscode"
ARG DESCRIPTION="VSCode back-end"
ARG MAINTAINER="Andrea F. Daniele (afdaniele@ttic.edu)"
# pick an icon from: https://fontawesome.com/v4.7.0/icons/
ARG ICON="code"

# ==================================================>
# ==> Do not change the code below this line
ARG ARCH=arm64v8
ARG DISTRO=ente
ARG BASE_TAG=${DISTRO}-${ARCH}
ARG BASE_IMAGE=dt-commons
ARG LAUNCHER=default

# define base image
ARG DOCKER_REGISTRY=docker.io
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

# check build arguments
RUN dt-build-env-check "${REPO_NAME}" "${MAINTAINER}" "${DESCRIPTION}"

# define/create repository path
ARG REPO_PATH="${SOURCE_DIR}/${REPO_NAME}"
ARG LAUNCH_PATH="${LAUNCH_DIR}/${REPO_NAME}"
RUN mkdir -p "${REPO_PATH}"
RUN mkdir -p "${LAUNCH_PATH}"
WORKDIR "${REPO_PATH}"

# keep some arguments as environment variables
ENV DT_MODULE_TYPE "${REPO_NAME}"
ENV DT_MODULE_DESCRIPTION "${DESCRIPTION}"
ENV DT_MODULE_ICON "${ICON}"
ENV DT_MAINTAINER "${MAINTAINER}"
ENV DT_REPO_PATH "${REPO_PATH}"
ENV DT_LAUNCH_PATH "${LAUNCH_PATH}"
ENV DT_LAUNCHER "${LAUNCHER}"

#HOT FIX FOR GPG ERROR
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# install apt dependencies
COPY ./dependencies-apt.txt "${REPO_PATH}/"
RUN dt-apt-install ${REPO_PATH}/dependencies-apt.txt

# install python3 dependencies
ARG PIP_INDEX_URL="https://pypi.org/simple"
ENV PIP_INDEX_URL=${PIP_INDEX_URL}
RUN echo PIP_INDEX_URL=${PIP_INDEX_URL}

COPY ./dependencies-py3.* "${REPO_PATH}/"
RUN python3 -m pip install  -r ${REPO_PATH}/dependencies-py3.txt

# copy the source code
COPY ./packages "${REPO_PATH}/packages"

# install launcher scripts
COPY ./launchers/. "${LAUNCH_PATH}/"
COPY ./launchers/default.sh "${LAUNCH_PATH}/"
RUN dt-install-launchers "${LAUNCH_PATH}"

# define default command
CMD ["bash", "-c", "dt-launcher-${DT_LAUNCHER}"]

# store module metadata
LABEL org.duckietown.label.module.type="${REPO_NAME}" \
    org.duckietown.label.module.description="${DESCRIPTION}" \
    org.duckietown.label.module.icon="${ICON}" \
    org.duckietown.label.architecture="${ARCH}" \
    org.duckietown.label.code.location="${REPO_PATH}" \
    org.duckietown.label.code.version.distro="${DISTRO}" \
    org.duckietown.label.base.image="${BASE_IMAGE}" \
    org.duckietown.label.base.tag="${BASE_TAG}" \
    org.duckietown.label.maintainer="${MAINTAINER}"
# <== Do not change the code above this line
# <==================================================

# install VSCode
ENV VSCODE_VERSION="4.5.0" \
    VSCODE_INSTALL_DIR="/opt/vscode" \
    VSCODE_PORT="8088" \
    VSCODE_USER_SETTINGS_DIR="/home/duckie/.local/share/code-server/User"
COPY ./assets/install-code-server.sh /tmp/install-code-server.sh
RUN /tmp/install-code-server.sh && \
    rm -f install-code-server.sh

# install dts
COPY ./assets/dts-run.sh /tmp/dts-run.sh
RUN bash /tmp/dts-run.sh && \
    rm -f dts-run.sh

# copy settings/keybindings file
ADD ./assets/settings.json "${VSCODE_USER_SETTINGS_DIR}/settings.json"
ADD ./assets/keybindings.json "${VSCODE_USER_SETTINGS_DIR}/keybindings.json"
ADD ./assets/tasks.json "${VSCODE_USER_SETTINGS_DIR}/tasks.json"

# install VSCode extensions
COPY ./assets/install-code-server-extensions.sh /tmp/install-code-server-extensions.sh
RUN /tmp/install-code-server-extensions.sh && \
    rm -f install-code-server-extensions.sh

# install Docker CLI
ENV DOCKER_CLI_VERSION="20.10.12"
COPY assets/install-docker-cli.sh /tmp/install-docker-cli.sh
RUN /tmp/install-docker-cli.sh && \
    rm /tmp/install-docker-cli.sh
