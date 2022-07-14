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
ARG COMMANDS_REPO="https://github.com/OSLL/duckietown-shell-commands.git"
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

# install apt dependencies
COPY ./dependencies-apt.txt "${REPO_PATH}/"

#HOT FIX FOR GPG ERROR
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN dt-apt-install ${REPO_PATH}/dependencies-apt.txt

# install python3 dependencies
ARG PIP_INDEX_URL="https://pypi.org/simple"
ENV PIP_INDEX_URL=${PIP_INDEX_URL}
RUN echo PIP_INDEX_URL=${PIP_INDEX_URL}

COPY ./dependencies-py3.txt "${REPO_PATH}/"
RUN pip3 install -r ${REPO_PATH}/dependencies-py3.txt

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

ENV HOSTNAME=${hostname}

ENV VSCODE_VERSION="4.4.0" \
    VSCODE_INSTALL_DIR="/opt/vscode" 

COPY ./assets/install-code-server.sh /tmp/install-code-server.sh
RUN /tmp/install-code-server.sh && \
    rm -f install-code-server.sh
ENV PATH="$PATH:/opt/vscode/bin/" \
    VSCODE_PORT="8088" 

# install dts

COPY ./assets/dts-run.sh /tmp/dts-run.sh
RUN bash /tmp/dts-run.sh && \
    rm -f dts-run.sh
RUN git clone "${COMMANDS_REPO}" /root/.local/share/code-server/User/duckietown-shell-commands
ENV DTSHELL_COMMANDS /root/.local/share/code-server/User/duckietown-shell-commands


COPY ./assets/runtime_docker.sh /tmp/runtime_docker.sh
RUN bash /tmp/runtime_docker.sh && \
   rm -f runtime_docker.sh 

# set settings
COPY ./assets/tasks.json /root/.local/share/code-server/User/ 
COPY ./assets/keybindings.json /root/.local/share/code-server/User/ 
COPY ./assets/settings.json /root/.local/share/code-server/User/ 