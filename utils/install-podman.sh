#!/bin/bash

set -e 

podman_exists() {
    podman version > /dev/null 2>&1
}

# Skip if already installed Podman
if podman_exists; then
  echo "Podman already installed"
  exit 0
fi

# Install Podman
# Ubuntu 20.10 and newer
sudo apt-get update
sudo apt-get -y install podman
sudo apt-get install qemu-system-x86

sudo apt-get install \
  btrfs-progs \
  gcc \
  git \
  golang-go \
  go-md2man \
  iptables \
  libassuan-dev \
  libbtrfs-dev \
  libc6-dev \
  libdevmapper-dev \
  libglib2.0-dev \
  libgpgme-dev \
  libgpg-error-dev \
  libprotobuf-dev \
  libprotobuf-c-dev \
  libseccomp-dev \
  libselinux1-dev \
  libsystemd-dev \
  make \
  netavark \
  passt \
  pkg-config \
  runc \
  uidmap

# If there is an issue with netavark, install containernetworking-plugins instead
sudo apt-get install containernetworking-plugins

# Enable user namespaces
# sudo sysctl kernel.unprivileged_userns_clone=1
# To enable user namespaces permanenetly
# echo 'kernel.unprivileged_userns_clone=1' > /etc/sysctl.d/userns.conf

# Download gvproxy
sudo wget https://github.com/containers/gvisor-tap-vsock/releases/download/v0.8.3/gvproxy-linux-amd64 -O /usr/libexec/podman/gvproxy
sudo chmod +x /usr/libexec/podman/gvproxy

# Attempting to get a newer version of Podman
# sudo wget https://github.com/containers/podman/releases/download/v5.3.2/podman-remote-static-linux_amd64.tar.gz -O /usr/bin/podman

# Test Podman installation
if podman_exists; then
    echo "Podman is successfully installed"
else
    echo "Podman installation failed"
    exit 1
fi
