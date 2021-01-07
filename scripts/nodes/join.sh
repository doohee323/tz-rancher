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

# make a cluster.yml file
rke config

# bootstrap k8s servers
rm -Rf cluster.rkestate
rm -Rf kube_config_cluster.yml
rke up --ignore-docker-version




exit 0

