#!/usr/bin/env bash

########################################################################
# - apply jenkins deployment and service
########################################################################
cp /vagrant/shared/jenkins_deployment.yaml .
cp /vagrant/shared/jenkins_service.yaml .

kubectl --kubeconfig ~/.kube/config apply -f jenkins_deployment.yaml
kubectl --kubeconfig ~/.kube/config apply -f jenkins_service.yaml

########################################################################
## - get jenkins url
########################################################################
# in Workloads
# => http://192.168.0.126:31891/

########################################################################
## - install jenkins plugins
########################################################################
# http://192.168.0.126:32203/pluginManager/available
# install kubernetes

########################################################################
## - make a secret key
########################################################################
https://192.168.0.155/apikeys
Add key >
Access Key (username):  token-bc4hf
Secret Key (password):: lxwpl7kfmftqjrdqfnq2m4dtth6cz9l7j4dzbxshb6qk669jq82gbh

########################################################################
## - setting kubernetes plugin
########################################################################
# http://192.168.0.126:32203/configureClouds/
# kubectl cluster-info
# Kubernetes Url: https://192.168.0.155
# Disable https certificate check: check
# Kubernetes Namespace: default
# Credentials: token-bc4hf / lxwpl7kfmftqjrdqfnq2m4dtth6cz9l7j4dzbxshb6qk669jq82gbh
# kubectl describe services/jenkins | grep IP
# IP:                       10.43.234.135
# Jenkins URL: http://10.43.234.135

# Pod Templates: slave1
#     Containers: slave1
#     Docker image: doohee323/jenkins-slave

########################################################################
## - make a job
########################################################################
# job name: slave1
# build > execute shell: echo "i am slave1"; sleep 60




