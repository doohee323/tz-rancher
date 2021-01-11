#!/usr/bin/env bash

set -x

192.168.0.130 k8s-master
192.168.0.169 node-1
192.168.0.123 node-2

#ssh 192.168.0.130
#Are you sure you want to continue connecting (yes/no)? yes
vi ~/.ssh/authorized_keys   # copy from rancher host, ubuntu's id_rsa.pub

# check access is ok
ssh -i ~/.ssh/id_rsa ubuntu@192.168.0.130
ssh -i ~/.ssh/id_rsa ubuntu@192.168.0.169
ssh -i ~/.ssh/id_rsa ubuntu@192.168.0.123

cd /home/ubuntu

# make a cluster.yml file
rke config

vi cluster.yml
#nodes:
#- address: 192.168.0.130
#  port: "22"
#  internal_address: ""
#  role:
#  - controlplane
#  - worker
#  - etcd
#  hostname_override: ""
#  user: ubuntu
#  docker_socket: /var/run/docker.sock
#  ssh_key: ""
#  ssh_key_path: /home/ubuntu/.ssh/id_rsa
#  ssh_cert: ""
#  ssh_cert_path: ""
#  labels: {}
#  taints: []
#- address: 192.168.0.169
#  user: ubuntu
#  role: [worker]
#- address: 192.168.0.123
#  user: ubuntu
#  role: [worker]
#services:

# bootstrap k8s servers
rm -Rf cluster.rkestate
rm -Rf kube_config_cluster.yml
#rke remove -dind --force
rke up --ignore-docker-version



########################################################################
# - import a cluster
########################################################################
## from Import Cluster page
## 1. create a cluster
##    Add Cluster > Other Cluster > Cluster Name: jenkins
## 2. import cluster
## https://10.0.0.10/g/clusters/add/launch/import?importProvider=other
## add "--kubeconfig=kube_config_cluster.yml"

#copy kube_config_cluster.yml from rancher server's /home/ubuntu
#to k8s master /home/ubuntu/.kube/config

kubectl --kubeconfig ~/.kube/config apply -f /vagrant/tz-local/resource/172.16_net_calico.yaml

su - ubuntu
curl --insecure -sfL https://192.168.0.185/v3/import/bccpxpttbl62bvj25l6b72mrkb2f45rkgxw7cr8fwwbrzg2h2dlnsf.yaml | kubectl apply -f -
or
wget https://192.168.0.185/v3/import/bccpxpttbl62bvj25l6b72mrkb2f45rkgxw7cr8fwwbrzg2h2dlnsf.yaml --no-check-certificate
kubectl apply -f bccpxpttbl62bvj25l6b72mrkb2f45rkgxw7cr8fwwbrzg2h2dlnsf.yaml

########################################################################
# - set .kube/config
########################################################################
# from https://10.0.0.10/c/c-65zvt/monitoring  # Global > Dashboard: jenkins
# download Kubeconfig File
mkdir -p /home/ubuntu/.kube
# vi /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config

echo "" >> /home/ubuntu/.bash_profile
echo "alias ll='ls -al'" >> /home/ubuntu/.bash_profile
echo "alias kk='kubectl --kubeconfig ~/.kube/config'" >> /home/ubuntu/.bash_profile
source /home/ubuntu/.bash_profile




exit 0

