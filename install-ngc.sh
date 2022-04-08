#! /bin/bash


#part 1
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

#part 2

sudo modprobe overlay \
    && sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo apt-get update

echo "installing now"
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo apt-get update \
    && sudo apt-get install -y containerd.io
sudo mkdir -p /etc/containerd \
    && sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo ctr image pull docker.io/library/hello-world:latest \
    && sudo ctr run --rm -t docker.io/library/hello-world:latest hello-world

echo "install nvidia container toolkit"
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - \
    && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update \
    && sudo apt-get install -y nvidia-container-toolkit

echo "let's test nvidia running"
sudo apt list --installed *nvidia*

echo "testing the installation"
sudo ctr image pull docker.io/nvidia/cuda:11.0-base
sudo ctr run --rm --gpus 0 -t docker.io/nvidia/cuda:11.0-base cuda-11.0-base nvidia-smi
