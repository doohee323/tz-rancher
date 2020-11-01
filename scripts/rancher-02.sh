#!/usr/bin/env bash

########################################################################
## - import a cluster
########################################################################
## from Import Cluster page
## 1. create a cluster
##    Add Cluster > Other Cluster > Cluster Name: jenkins
## 2. import cluster
## https://192.168.0.155/g/clusters/add/launch/import?importProvider=other
## add "--kubeconfig=kube_config_cluster.yml"
su - centos
curl --insecure -sfL https://192.168.0.155/v3/import/2lb9zn7p69gk22jhgwmggfrtrccvt887szzmgh4szfz2rm8hjk98bk.yaml | kubectl apply -f --kubeconfig=kube_config_cluster.yml -

or

wget https://192.168.0.155/v3/import/2lb9zn7p69gk22jhgwmggfrtrccvt887szzmgh4szfz2rm8hjk98bk.yaml --no-check-certificate
kubectl apply -f 2lb9zn7p69gk22jhgwmggfrtrccvt887szzmgh4szfz2rm8hjk98bk.yaml --kubeconfig=kube_config_cluster.yml

########################################################################
# - set .kube/config
########################################################################
# from https://192.168.0.155/c/c-65zvt/monitoring  # Global > Dashboard: jenkins
# download Kubeconfig File
mkdir -p /home/centos/.kube
# vi /home/centos/.kube/config
sudo chown centos:centos /home/centos/.kube/config

echo "" >> /home/centos/.bash_profile
echo "alias ll='ls -al'" >> /home/centos/.bash_profile
echo "alias kk='kubectl --kubeconfig ~/.kube/config'" >> /home/centos/.bash_profile
source /home/centos/.bash_profile





