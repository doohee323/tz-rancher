#!/usr/bin/env bash

set -x

#ssh 10.0.0.11
#Are you sure you want to continue connecting (yes/no)? yes

# check access is ok
#ssh -i ~/.ssh/id_rsa ubuntu@10.0.0.11

cd /home/ubuntu

########################################################################
# - Add k8s host into rancher
########################################################################
# rke config    ## host -> k8s host
#[+] Cluster Level SSH Private Key Path [~/.ssh/id_rsa]:
#[+] Number of Hosts [1]:
#[+] SSH Address of host (1) [none]: 10.0.0.11
#[+] SSH Port of host (1) [22]:
#[+] SSH Private Key Path of host (10.0.0.11) [none]: /home/ubuntu/.ssh/id_rsa
#[+] SSH User of host (10.0.0.11) [ubuntu]: ubuntu
#[+] Is host (10.0.0.11) a Control Plane host (y/n)? [y]:
#[+] Is host (10.0.0.11) a Worker host (y/n)? [n]: y
#[+] Is host (10.0.0.11) an etcd host (y/n)? [n]: y
#[+] Override Hostname of host (10.0.0.11) [none]:
#[+] Internal IP of host (10.0.0.11) [none]:
#[+] Docker socket path on host (10.0.0.11) [/var/run/docker.sock]:
#[+] Network Plugin Type (flannel, calico, weave, canal) [canal]:
#[+] Authentication Strategy [x509]:
#[+] Authorization Mode (rbac, none) [rbac]:
#[+] Kubernetes Docker image [rancher/hyperkube:v1.19.3-rancher1]:
#[+] Cluster domain [cluster.local]:
#[+] Service Cluster IP Range [10.43.0.0/16]:
#[+] Enable PodSecurityPolicy [n]:
#[+] Cluster Network CIDR [10.42.0.0/16]:
#[+] Cluster DNS Service IP [10.43.0.10]:
#[+] Add addon manifest URLs or YAML files [no]:

sudo cp /vagrant/shared/cluster.yml /home/ubuntu
ls cluster.yml

########################################################################
# - rke up (with ubuntu account)
########################################################################
sudo chown -Rf ubuntu:ubuntu /var/run/docker.sock
docker ps
rm -Rf /home/ubuntu/cluster.rkestate
rm -Rf /home/ubuntu/kube_config_cluster.yml
rke up --ignore-docker-version

ls /home/ubuntu/kube_config_cluster.yml

exit 0

