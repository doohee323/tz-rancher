#!/usr/bin/env bash

set -x

##################################################################
# k8s node
##################################################################

sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab
sudo apt-get update
sudo apt-get install -y docker.io apt-transport-https curl
sudo systemctl start docker
sudo systemctl enable docker

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "group": "ubuntu"
}
EOF

sudo service docker restart
sudo systemctl enable docker

sudo useradd -m ubuntu -g ubuntu -s /bin/bash
echo -e "ubuntu\nubuntu" | passwd ubuntu
sudo mkdir /home/ubuntu
sudo chown ubuntu:ubuntu /home/ubuntu
sudo groupadd docker
sudo usermod -aG docker ubuntu

#add /etc/sudoers
cat <<EOF | sudo tee /etc/sudoers.d/rancher
ubuntu ALL=(ALL) NOPASSWD:ALL
EOF

sudo mkdir /home/ubuntu/.ssh
sudo chown -Rf ubuntu:ubuntu /home/ubuntu
sudo chmod 700 /home/ubuntu/.ssh
sudo cp /vagrant/shared/authorized_keys /home/ubuntu/.ssh/authorized_keys
sudo chmod 640 /home/ubuntu/.ssh/authorized_keys
sudo chown -Rf ubuntu:ubuntu /var/run/docker.sock
docker ps

exit 0
