#! /bin/bash

echo "Making docker run without sudo"
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

echo "enabling docker on boot"
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
