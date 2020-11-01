#!/usr/bin/env bash

set -x

##################################################################
# k8s node
##################################################################

yum install docker -y

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "group": "root"
}
EOF

sudo service docker restart
sudo systemctl enable docker

useradd centos
echo "centos" | passwd --stdin centos
sudo usermod -aG dockerroot centos

#add /etc/sudoers
cat <<EOF | sudo tee /etc/sudoers.d/rancher
centos ALL=(ALL) NOPASSWD:ALL
EOF

sudo mkdir /home/centos/.ssh
sudo chown -Rf centos:centos /home/centos/.ssh
sudo chmod 700 /home/centos/.ssh
sudo cp /vagrant/shared/authorized_keys /home/centos/.ssh/authorized_keys
sudo chmod 640 /home/centos/.ssh/authorized_keys

sudo chown -Rf centos:centos /var/run/docker.sock
docker ps

exit 0
