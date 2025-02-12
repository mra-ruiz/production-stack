#!/bin/bash

set -e 

kind_exists() {
  which kind >/dev/null 2>&1
}

# Install kind
if kind_exists; then
  echo "Kind already installed"
else
  [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.26.0/kind-linux-amd64
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind
fi