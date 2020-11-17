#!/usr/bin/env bash

set -x


# https://rancher.com/docs/rancher/v2.x/en/installation/other-installation-methods/single-node-docker/

##################################################################
# - install docker
##################################################################
sudo su

sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -y install docker-ce
sudo systemctl start docker
sudo systemctl enable docker

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "group": "root"
}
EOF

sudo service docker restart
sudo systemctl enable docker

sudo groupadd ubuntu
sudo useradd -m ubuntu -g ubuntu -s /bin/bash
echo -e "ubuntu\nubuntu" | passwd ubuntu
sudo mkdir -p /home/ubuntu
sudo chown ubuntu:ubuntu /home/ubuntu
sudo groupadd docker
sudo usermod -aG docker ubuntu

#add /etc/sudoers
cat <<EOF | sudo tee /etc/sudoers.d/rancher
ubuntu ALL=(ALL) NOPASSWD:ALL
vagrant ALL=(ALL) NOPASSWD:ALL
EOF

##################################################################
# - install rancher
##################################################################
docker run -d --restart=unless-stopped \
  -p 80:80 -p 443:443 \
  --privileged \
  rancher/rancher:latest

sleep 120
echo docker ps | grep 'rancher/rancher' | awk '{print $1}' | xargs docker logs -f

echo "##################################################################"
echo " Rancher URL: https://10.0.0.10"
echo "##################################################################"

##################################################################
# - install rke
##################################################################
#sudo service docker restart

sudo wget https://github.com/rancher/rke/releases/download/v1.2.1/rke_linux-amd64
sudo mv rke_linux-amd64 /usr/bin/rke
sudo chmod 755 /usr/bin/rke
rke -v

##################################################################
# - rke config (with ubuntu account)
##################################################################
sudo chown -Rf ubuntu:ubuntu /home/ubuntu
sudo su - ubuntu
sudo mkdir -p /home/ubuntu/.ssh
cd /home/ubuntu/.ssh
ssh-keygen -t rsa -C ubuntu -P "" -f /home/ubuntu/.ssh/id_rsa -q
sudo chmod 600 /home/ubuntu/.ssh/id_rsa
eval `ssh-agent`
ssh-add id_rsa

cat <<EOF | sudo tee /home/ubuntu/.ssh/config
Host 10.0.0.*
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  IdentitiesOnly yes
EOF

sudo chown -Rf ubuntu:ubuntu /home/ubuntu/.ssh

sudo mkdir -p /vagrant/shared
sudo cp -Rf /home/ubuntu/.ssh/id_rsa.pub /vagrant/shared/authorized_keys
#sudo chmod 700 /home/ubuntu/.ssh
#sudo chmod 640 /home/ubuntu/.ssh/authorized_keys

########################################################################
# - install kubectl
########################################################################
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2 curl
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

cd /home/ubuntu

sudo bash /vagrant/scripts/ubuntu/rancher-01.sh

echo ########################################################################
echo Need to run and follow two shells!!!
echo
echo bash /vagrant/scripts/ubuntu/rancher-02.sh
echo bash /vagrant/scripts/ubuntu/rancher-03.sh
echo ########################################################################
