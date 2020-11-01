#!/usr/bin/env bash

set -x

# https://rancher.com/docs/rancher/v2.x/en/installation/other-installation-methods/single-node-docker/

##################################################################
## - install docker
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

sudo groupadd docker
sudo usermod -aG docker centos

#add /etc/sudoers
cat <<EOF | sudo tee /etc/sudoers.d/rancher
centos ALL=(ALL) NOPASSWD:ALL
EOF

##################################################################
## - install rancher
##################################################################
docker run -d --restart=unless-stopped \
  -p 80:80 -p 443:443 \
  --privileged \
  rancher/rancher:latest

sleep 120
echo docker ps | grep 'rancher/rancher' | awk '{print $1}' | xargs docker logs -f
#curl https://10.0.0.10

##################################################################
# - install rke
##################################################################
#sudo service docker restart

yum install wget -y
wget https://github.com/rancher/rke/releases/download/v1.2.1/rke_linux-amd64
mv rke_linux-amd64 /usr/bin/rke
chmod 755 /usr/bin/rke
rke -v

##################################################################
# - rke config (with centos account)
##################################################################
sudo chown -Rf centos:centos /home/centos
#su - centos
mkdir /home/centos/.ssh
cd /home/centos/.ssh
ssh-keygen -t rsa -C centos -P "" -f /home/centos/.ssh/id_rsa -q
sudo chown centos:centos /home/centos/.ssh/id_rsa
sudo chmod 600 /home/centos/.ssh/id_rsa
eval `ssh-agent`
ssh-add id_rsa

sudo mkdir /vagrant/shared
sudo cp /home/centos/.ssh/id_rsa.pub /vagrant/shared/authorized_keys
#sudo chmod 700 /home/centos/.ssh
#sudo chmod 640 /home/centos/.ssh/authorized_keys

########################################################################
# - install kubectl
########################################################################
sudo su
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubectl

cd /home/centos

bash /vagrant/scripts/rancher-01.sh

echo ########################################################################
echo Need to run and follow two shells!!!
echo
echo bash /vagrant/scripts/rancher-02.sh
echo bash /vagrant/scripts/rancher-03.sh
echo ########################################################################

exit 0




