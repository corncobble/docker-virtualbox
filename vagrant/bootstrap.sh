#!/bin/bash

set -e

# Install packages via apt
apt-get update
apt-get install -y --no-install-recommends apt-transport-https gnupg

# Install docker package repository
DOCKER_SOURCELIST=/etc/apt/sources.list.d/docker.list
if [[ ! -f $DOCKER_SOURCELIST ]]; then
    source /etc/os-release
    KEYRING_DIR=/etc/apt/keyrings
    mkdir $KEYRING_DIR
    wget -O- https://download.docker.com/linux/${ID}/gpg | gpg --dearmor -o ${KEYRING_DIR}/docker-${ID}.gpg
    echo "deb [arch=amd64 signed-by=${KEYRING_DIR}/docker-${ID}.gpg] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | tee $DOCKER_SOURCELIST
    apt-get update
fi

# Install docker
apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user vagrant to group docker
usermod -aG docker vagrant

# Drop-in systemd file to override Docker ExecStart (startup)
mkdir -p /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/startup-remote.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375 --containerd=/run/containerd/containerd.sock
EOF
systemctl daemon-reload
systemctl restart docker