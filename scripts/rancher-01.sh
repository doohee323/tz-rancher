#!/usr/bin/env bash

set -x

#ssh 192.168.0.126
#Are you sure you want to continue connecting (yes/no)? yes

# check access is ok
#ssh -i ~/.ssh/id_rsa centos@192.168.0.126

cd /home/centos

########################################################################
# - Add k8s host into rancher
########################################################################
# rke config    ## host -> k8s host
#[+] Cluster Level SSH Private Key Path [~/.ssh/id_rsa]:
#[+] Number of Hosts [1]:
#[+] SSH Address of host (1) [none]: 192.168.0.126
#[+] SSH Port of host (1) [22]:
#[+] SSH Private Key Path of host (45.79.109.174) [none]: /home/centos/.ssh/id_rsa
#[+] SSH User of host (45.79.109.174) [ubuntu]: centos
#[+] Is host (45.79.109.174) a Control Plane host (y/n)? [y]:
#[+] Is host (45.79.109.174) a Worker host (y/n)? [n]: y
#[+] Is host (45.79.109.174) an etcd host (y/n)? [n]: y
#[+] Override Hostname of host (45.79.109.174) [none]:
#[+] Internal IP of host (45.79.109.174) [none]:
#[+] Docker socket path on host (45.79.109.174) [/var/run/docker.sock]:
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

sudo cp /vagrant/shared/cluster.yml /home/centos
ls cluster.yml

########################################################################
# - rke up (with centos account)
########################################################################
sudo chown -Rf centos:centos /var/run/docker.sock
docker ps
rm -Rf /home/centos/cluster.rkestate
rm -Rf /home/centos/kube_config_cluster.yml
rke up

ls /home/centos/kube_config_cluster.yml

exit 0

