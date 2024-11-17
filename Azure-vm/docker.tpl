#!/bin/bash
set -ex
# Update the apt package index and install packages to allow apt to use a repository over HTTPS
sudo apt update -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
# Add Docker official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# The following command is to set up the stable repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu `lsb_release -cs` stable"
# Update the apt package index, and install the latest version of Docker Engine and containerd, or go to the next step to install a specific version
sudo apt update -y
sudo apt install -y docker-ce -y
sleep 30
sudo groupadd docker
sudo usermod -aG docker ubuntu
#Allow permision to root user
sudo chmod 666 /var/run/docker.sock