#!/usr/bin/env bash

########################################################################
## - import a cluster
########################################################################
## from Import Cluster page
## 1. create a cluster
##    Add Cluster > Other Cluster > Cluster Name: jenkins
## 2. import cluster
## https://192.168.0.100/g/clusters/add/launch/import?importProvider=other
## add "--kubeconfig=kube_config_cluster.yml"
su - centos
curl --insecure -sfL https://192.168.0.100/v3/import/bnk89tsbqdqtxhzcdvpgxrfgb9hq7bsxjhqld2mxgmrxmbsnlrz57d.yaml | kubectl apply -f --kubeconfig=kube_config_cluster.yml -

########################################################################
# - set .kube/config
########################################################################
# from https://192.168.0.100/c/c-65zvt/monitoring  # Global > Dashboard: jenkins
# download Kubeconfig File
mkdir -p /home/centos/.kube
# vi /home/centos/.kube/config
sudo chown centos:centos /home/centos/.kube/config

echo "" >> /home/centos/.bash_profile
echo "alias ll='ls -al'" >> /home/centos/.bash_profile
echo "alias kk='kubectl --kubeconfig ~/.kube/config'" >> /home/centos/.bash_profile
source /home/centos/.bash_profile

########################################################################
## - import a cluster
########################################################################
## from Import Cluster page
## 1. create a cluster
##    Add Cluster > Other Cluster > Cluster Name: jenkins
## 2. import cluster
## https://192.168.0.100/g/clusters/add/launch/import?importProvider=other
## add "--kubeconfig=kube_config_cluster.yml"
#su - centos
curl --insecure -sfL https://192.168.0.100/v3/import/bnk89tsbqdqtxhzcdvpgxrfgb9hq7bsxjhqld2mxgmrxmbsnlrz57d.yaml | kubectl apply -f --kubeconfig=kube_config_cluster.yml -

########################################################################
## - make a secret key
########################################################################
https://192.168.0.100/apikeys
Add key >
Access Key (username):  token-m5dx2
Secret Key (password):: ddzxx6f5h6spnf45vxzxrm77pb9srpqjncrwmt8ghxsd7fbmgwkv87





