# Jenkins on Kubernetes with Rancher

## build a jenkins env on CentOS in vagrant
```
vagrant up
vagrant destroy -f

Need to run and follow two shells on rancher
vagrant ssh rancher
vi /vagrant/scripts/centos/rancher-02.sh
vi /vagrant/scripts/centos/rancher-03.sh

```

## build a jenkins env on ubuntu in vagrant
scripts/ubuntu/rancher.sh

## build a jenkins env on CentOS in aws / linode with k8s
scripts/aws/rancher.sh
scripts/linod/rancher.sh




