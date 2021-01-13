#!/usr/bin/env bash

########################################################################
# - import a cluster
########################################################################
## from Import Cluster page
## 1. create a cluster
##    Add Cluster > Other Cluster > Cluster Name: jenkins
## 2. import cluster
## https://10.0.0.10/g/clusters/add/launch/import?importProvider=other
## add "--kubeconfig=kube_config_cluster.yml"
su - ubuntu
curl --insecure -sfL https://192.168.0.180/v3/import/7ms892bw5pvjs9drjv4nddvfbkg27hgpfwt7x58pcn8t5cp5bxwb7k.yaml | kubectl apply -f -
or

wget https://192.168.0.180/v3/import/7ms892bw5pvjs9drjv4nddvfbkg27hgpfwt7x58pcn8t5cp5bxwb7k.yaml --no-check-certificate
kubectl apply -f 7ms892bw5pvjs9drjv4nddvfbkg27hgpfwt7x58pcn8t5cp5bxwb7k.yaml


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





