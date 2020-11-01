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
# => http://192.168.0.130:32203/

########################################################################
## - install jenkins plugins
########################################################################
# http://192.168.0.130:32203/pluginManager/available
# install kubernetes and green balls

########################################################################
## - setting kubernetes plugin
########################################################################
# http://192.168.0.130:32203/configureClouds/

# kubectl cluster-info
# Kubernetes Url: https://192.168.0.100
# Disable https certificate check: check
# Kubernetes Namespace: default
# Credentials: token-m5dx2 / ddzxx6f5h6spnf45vxzxrm77pb9srpqjncrwmt8ghxsd7fbmgwkv87
# kubectl describe services/jenkins | grep IP
# IP:                       10.43.156.129
# Jenkins URL: http://10.43.156.129

# Pod Templates: slave1
#     Containers: slave1
#     Docker image: doohee323/jenkins-slave

########################################################################
## - make a job
########################################################################
# job name: slave1
# build > execute shell: echo "i am slave1"; sleep 60




