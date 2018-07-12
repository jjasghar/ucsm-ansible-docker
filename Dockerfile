FROM alpine:3.7

ARG BUILD_DATE
LABEL org.label-schema.build-date=$BUILD_DATE
 
ENV ANSIBLE_VERSION 2.5.5
ENV UCSMSDK_VERSION 0.9.3.2
ENV BUILD_PACKAGES \
  openssh-client \
  sshpass \
  git \
  python \
  py-dateutil \
  py-httplib2 \
  py-jinja2 \
  py-paramiko \
  py-pip \
  py-yaml \
  ca-certificates

COPY src/ucsm_apis /tmp/ucsm_apis

RUN set -x && \
    \
    echo "==> Adding build-dependencies..."  && \
    apk --update add --virtual build-dependencies \
      gcc \
      musl-dev \
      libffi-dev \
      openssl-dev \
      python-dev && \
    \
    echo "==> Upgrading apk and system..."  && \
    apk update && apk upgrade && \
    \
    echo "==> Adding Python runtime..."  && \
    apk add --no-cache ${BUILD_PACKAGES} && \
    pip install --upgrade pip && \
    echo "==> Installing Ansible..."  && \
    pip install --no-cache ansible==${ANSIBLE_VERSION} && \
    echo "==> Installing ucsmsdk..."  && \
    pip install --no-cache ucsmsdk==${UCSMSDK_VERSION}&& \
    \
    echo "==> Installing ucsm_apis" && \
    cd /tmp/ucsm_apis && \
    python ./setup.py install && \
    rm -rf /tmp/ucsm_apis && \
    \
    echo "==> Cleaning up..."  && \
    apk del build-dependencies \
      build-base \
      libffi-dev \ 
      openssl-dev \
      musl-dev && \
    rm -rf /var/cache/apk/* && \
    \
    echo "==> Adding hosts for convenience..."  && \
    mkdir -p /etc/ansible /ansible && \
    echo "[local]" >> /etc/ansible/hosts && \
    echo "localhost" >> /etc/ansible/hosts
 
ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV PYTHONPATH /ansible/lib
ENV PATH /ansible/bin:$PATH
ENV ANSIBLE_LIBRARY /ansible/library

WORKDIR /ansible/playbooks
 
ENTRYPOINT ["ansible-playbook"]