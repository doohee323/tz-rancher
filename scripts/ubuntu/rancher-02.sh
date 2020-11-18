#!/usr/bin/env bash

# - rke up (with ubuntu account)
sudo su - ubuntu
rke up

########################################################################
# - set .kube/config for node status
########################################################################
sudo mkdir -p /home/ubuntu/.kube
sudo cp -Rf /home/ubuntu/kube_config_cluster.yml /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config

echo "" >> /home/ubuntu/.bash_profile
echo "alias ll='ls -al'" >> /home/ubuntu/.bash_profile
echo "alias k='kubectl --kubeconfig ~/.kube/config'" >> /home/ubuntu/.bash_profile
source /home/ubuntu/.bash_profile

k get nodes

########################################################################
# - import a cluster
########################################################################
## from Import Cluster page
## 1. create a cluster
##    Add Cluster > Other Cluster > Cluster Name: jenkins
## 2. import cluster
## https://10.0.0.10/g/clusters/add/launch/import?importProvider=other
## add "--kubeconfig=kube_config_cluster.yml"
sudo su - ubuntu
curl --insecure -sfL https://10.0.0.10/v3/import/x2gwc99hr8gmkgvfpgdplnmspgvtzj9zr5tg26rxlnbsbbqp8bswcz.yaml | kubectl apply -f --kubeconfig=kube_config_cluster.yml -
or
wget https://10.0.0.10/v3/import/x2gwc99hr8gmkgvfpgdplnmspgvtzj9zr5tg26rxlnbsbbqp8bswcz.yaml --no-check-certificate
kubectl apply -f x2gwc99hr8gmkgvfpgdplnmspgvtzj9zr5tg26rxlnbsbbqp8bswcz.yaml --kubeconfig=kube_config_cluster.yml

########################################################################
# - set .kube/config
########################################################################
# from https://10.0.0.10/c/c-65zvt/monitoring  # Global > Dashboard: jenkins
# download Kubeconfig File
# vi /home/ubuntu/.kube/config

k get nodes
