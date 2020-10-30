#!/usr/bin/env bash

#https://rancher.com/docs/rancher/v2.x/en/installation/other-installation-methods/single-node-docker/

##################################################################
# rancher server  => 54.157.32.188 / 172.31.18.155
##################################################################
# aws: ssh -i ~/.ssh/dewey_ca1.pem centos@54.151.71.102
# linode: ssh -i ~/.ssh/doohee323 root@45.79.109.174

## 1) open ports
# all ports: https://rancher.com/docs/rancher/v2.x/en/installation/requirements/ports/
#add rancher1 security group
#open tcp 22, 80, 443, 2379, 6443, 10250 inbound 
#open udp 8472 inbound 

#ssh -i ~/.ssh/dewey_ca1.pem centos@54.183.236.40

sudo su 

## 2) install docker
yum install docker -y

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "group": "root"
}
EOF

sudo service docker restart
sudo systemctl enable docker

useradd centos
sudo usermod -aG dockerroot centos

docker run -d --restart=unless-stopped \
  -p 80:80 -p 443:443 \
  --privileged \
  rancher/rancher:latest

docker ps | grep 'rancher/rancher' | awk '{print $1}' | xargs docker logs -f

curl http://54.183.236.40  

##################################################################
# k8s host => 54.227.63.220 / 172.31.20.96
##################################################################
# aws: ssh -i ~/.ssh/dewey_ca1.pem centos@54.193.112.157
# linode: ssh -i ~/.ssh/doohee323 root@45.79.78.194
sudo su
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
#centos ALL=(ALL) NOPASSWD:ALL

## 3) install rke

sudo systemctl enable docker
sudo service docker restart

yum install wget -y
wget https://github.com/rancher/rke/releases/download/v1.2.1/rke_linux-amd64
mv rke_linux-amd64 /usr/bin/rke
chmod 755 /usr/bin/rke
rke -v

## 4) rke config (with centos account)
sudo chown -Rf centos:centos /home/centos/.ssh
su - centos
mkdir /home/centos/.ssh
# copy from mine /Users/dhong/.ssh/doohee323
# scp -i ~/.ssh/dewey_ca1.pem /Users/dhong/.ssh/doohee323 centos@54.193.112.157:/home/centos/.ssh/id_rsa
# scp -i ~/.ssh/doohee323 /Users/dhong/.ssh/doohee323 root@45.79.78.194:/home/centos/.ssh/id_rsa
ll /home/centos/.ssh/id_rsa

sudo chmod 700 /home/centos/.ssh
chmod 640 .ssh/authorized_keys
cd /home/centos/.ssh
chmod 600 id_rsa
eval `ssh-agent`
ssh-add id_rsa

# add authorized_keys from /Users/dhong/.ssh/doohee323.pub
ssh 54.193.112.157
ssh 45.79.78.194
Are you sure you want to continue connecting (yes/no)? yes  # known_host

sudo chown -Rf centos:centos /var/run/docker.sock

rke config
[+] Cluster Level SSH Private Key Path [~/.ssh/id_rsa]:
[+] Number of Hosts [1]:
[+] SSH Address of host (1) [none]: 54.153.74.191
[+] SSH Port of host (1) [22]:
[+] SSH Private Key Path of host (54.153.74.191) [none]: /home/centos/.ssh/id_rsa
[+] SSH User of host (54.153.74.191) [ubuntu]: centos
[+] Is host (54.153.74.191) a Control Plane host (y/n)? [y]:
[+] Is host (54.153.74.191) a Worker host (y/n)? [n]: y
[+] Is host (54.153.74.191) an etcd host (y/n)? [n]: y
[+] Override Hostname of host (54.153.74.191) [none]:
[+] Internal IP of host (54.153.74.191) [none]:
[+] Docker socket path on host (54.153.74.191) [/var/run/docker.sock]:
[+] Network Plugin Type (flannel, calico, weave, canal) [canal]:
[+] Authentication Strategy [x509]:
[+] Authorization Mode (rbac, none) [rbac]:
[+] Kubernetes Docker image [rancher/hyperkube:v1.19.3-rancher1]:
[+] Cluster domain [cluster.local]:
[+] Service Cluster IP Range [10.43.0.0/16]:
[+] Enable PodSecurityPolicy [n]:
[+] Cluster Network CIDR [10.42.0.0/16]:
[+] Cluster DNS Service IP [10.43.0.10]:
[+] Add addon manifest URLs or YAML files [no]:

ll cluster.yml

## 5) rke up (with centos account)
rke up

ll kube_config_cluster.yml

## 6) install kubectl
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

## from Import Cluster page
## https://54.183.236.40/g/clusters/add/launch/import?importProvider=other
## add "--kubeconfig=kube_config_cluster.yml"
su - centos
curl --insecure -sfL https://54.151.71.102/v3/import/zpjndkb2tkj9vd5fllq4mht5xgsnh5zdxc47cqpzw48rv9k2b42zsq.yaml | kubectl apply --kubeconfig=kube_config_cluster.yml -f -



vi Dockerfile

FROM jenkins/jenkins:lts

COPY plugins.sh /usr/local/bin/install.plugins.sh
RUN /usr/local/bin/install.plugins.sh kubernetes
RUN /usr/local/bin/install.plugins.sh greenballs

USER jenkins


FROM jenkins:latest
USER root
RUN apt-get update && apt-get install -y build-essential
USER jenkins


FROM jenkins/jenkins:latest
VOLUME /var/jenkins_home
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
# install jenkins plugins
COPY ./jenkins-plugins /usr/share/jenkins/plugins
RUN while read i ; \ 
      do /usr/local/bin/install-plugins.sh $i ; \
    done < /usr/share/jenkins/plugins




docker build -t doohee323/jenkins-master


docker build -t doohee323/jenkins-master ./


https://coding-start.tistory.com/326

sudo docker run -d --name jenkins -p 8080:8080 -p 50000:50000 \
  -v /home/deploy/jenkins_v:/var/jenkins_home jenkins/jenkins:lts

sudo docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword

useradd docker
groupadd docker
sudo chown -Rf docker:docker /home/centos/jenkins_v
sudo chmod -Rf 777 /home/centos/jenkins_v

docker run --name centos -p 8080:8080 -p 50000:50000 \
  -v /home/centos/jenkins_v:/var/jenkins_home jenkins/jenkins:lts


yum -y update 
yum -y install docker docker-registry

sudo usermod -aG docker root 

sudo useradd jenkins
sudo grep jenkins /etc/passwd
sudo chown -Rf centos:centos /home/jenkins/jenkins_v

sudo chown -Rf centos:centos /var/run/docker.sock

sudo chmod -Rf 777 /var/run/docker.sock



mkdir $PWD/jenkins
sudo chown -R 1000:1000 $PWD/jenkins
docker run -p 8080:8080 -p 50000:50000 -v $PWD/jenkins:/var/jenkins_home --name jenkins jenkins

