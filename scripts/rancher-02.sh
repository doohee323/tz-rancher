#!/usr/bin/env bash

########################################################################
## - import a cluster
########################################################################
## from Import Cluster page
## 1. create a cluster
##    Add Cluster > Other Cluster > Cluster Name: jenkins
## 2. import cluster
## https://10.0.0.10/g/clusters/add/launch/import?importProvider=other
## add "--kubeconfig=kube_config_cluster.yml"
su - centos
curl --insecure -sfL https://10.0.0.10/v3/import/662nm5mdlg9k4m75dg8g55w9624427hdkblg464zrnhxcdsvdgm6s2.yaml | kubectl apply -f --kubeconfig=kube_config_cluster.yml -

or

wget https://10.0.0.10/v3/import/662nm5mdlg9k4m75dg8g55w9624427hdkblg464zrnhxcdsvdgm6s2.yaml --no-check-certificate
kubectl apply -f 662nm5mdlg9k4m75dg8g55w9624427hdkblg464zrnhxcdsvdgm6s2.yaml --kubeconfig=kube_config_cluster.yml

########################################################################
# - set .kube/config
########################################################################
# from https://10.0.0.10/c/c-65zvt/monitoring  # Global > Dashboard: jenkins
# download Kubeconfig File
mkdir -p /home/centos/.kube
# vi /home/centos/.kube/config
sudo chown centos:centos /home/centos/.kube/config

echo "" >> /home/centos/.bash_profile
echo "alias ll='ls -al'" >> /home/centos/.bash_profile
echo "alias kk='kubectl --kubeconfig ~/.kube/config'" >> /home/centos/.bash_profile
source /home/centos/.bash_profile





