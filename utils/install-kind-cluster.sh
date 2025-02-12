#!/bin/bash
set -e

nvidia_container_toolkit_exists() {
  which nvidia-container-toolkit >/dev/null 2>&1
}

# Install kubectl, helm, kind, and docker
bash ./install-kubectl.sh
bash ./install-helm.sh
bash ./install-kind.sh
bash ./install-docker.sh

# Install nvidia-container-toolkit
if nvidia_container_toolkit_exists; then
  echo "Nvidia container toolkit already installed"
else
  echo "--------- INSTALLING NVIDIA CONTAINER TOOLKIT -------"
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

  sudo apt-get update
  sudo apt-get install -y nvidia-container-toolkit
fi

echo "--------- CONFIGURING NVIDIA CONTAINER TOOLKIT -------"
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
nvidia-ctk cdi list
nvidia-ctk runtime configure --runtime=docker --set-as-default
systemctl restart docker

# set in file below:  accept-nvidia-visible-devices-as-volume-mounts = true
vi /etc/nvidia-container-runtime/config.toml

echo "--------- CREATING KIND CLUSTER -------"
kind create cluster --config kind-cluster-config.yaml

  echo "--------- CONFIGURING NVIDIA CONTAINER TOOLKIT -------"
  #sudo nvidia-ctk runtime configure --runtime=podman && sudo systemctl restart podman
  sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
  nvidia-ctk cdi list
fi

echo "--------- CREATING KIND CLUSTER -------"
# export KIND_EXPERIMENTAL_PROVIDER=podman
kind create cluster --config ../../../.kube/config.yaml

echo "--------- INSTALLING GPU OPERATOR -------"
sudo helm repo add nvidia https://helm.ngc.nvidia.com/nvidia && sudo helm repo update

# sudo helm install --wait --generate-name -n gpu-operator --create-namespace nvidia/gpu-operator --version=v24.9.1
helm install --wait --generate-name -n gpu-operator --create-namespace nvidia/gpu-operator --set driver.enabled=false
