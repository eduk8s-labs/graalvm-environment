ARG IMAGE_REPOSITORY=quay.io/eduk8s

ARG WORKSHOP_BASE_IMAGE_NAME=jdk11-environment
ARG WORKSHOP_BASE_IMAGE_TAG=210508.022420.1da6880

ARG WORKSHOP_BASE_IMAGE=${IMAGE_REPOSITORY}/${WORKSHOP_BASE_IMAGE_NAME}:${WORKSHOP_BASE_IMAGE_TAG}

FROM ${WORKSHOP_BASE_IMAGE} as graalvm-installation

RUN curl -sL https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.1.0/graalvm-ce-java11-linux-amd64-21.1.0.tar.gz --output /tmp/graalvm.tar.gz && \
    echo "39252954d2cb16dbc8ce4269f8b93a326a0efffdce04625615e827fe5b5e4ab7 /tmp/graalvm.tar.gz" | sha256sum --check --status && \
    mkdir /opt/graalvm && \
    tar -C /opt/graalvm --strip-components=1 -xvf /tmp/graalvm.tar.gz && \
    rm -rf /tmp/graalvm.tar.gz

ENV PATH=/opt/graalvm/bin:$PATH \
    JAVA_HOME=/opt/graalvm

RUN gu install native-image

FROM ${WORKSHOP_BASE_IMAGE}

USER root

RUN HOME=/root && \
    INSTALL_PKGS="zlib-devel" && \
    dnf install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    dnf clean -y --enablerepo='*' all

USER 1001

COPY --from=graalvm-installation --chown=1001:0 /opt/graalvm /opt/graalvm

ENV PATH=/opt/graalvm/bin:$PATH \
    JAVA_HOME=/opt/graalvm
