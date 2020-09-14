#!/bin/bash

# https://rancher.com/docs/rancher/v2.x/en/installation/other-installation-methods/single-node-docker/

sudo su

sudo service docker restart

docker run -d --restart=unless-stopped \
  -p 80:80 -p 443:443 \
  rancher/rancher:latest

docker ps | awk '{print $1}' | tail -n 1 | xargs docker logs -f 
docker ps | awk '{print $1}' | tail -n 1 | xargs docker stop d2cbc7a5670c

docker run -d --restart=unless-stopped --privileged \
  -p 9080:80 -p 9443:443 \
  -v /rancher:/var/lib/rancher \
  rancher/rancher:latest

curl https://localhost:9443/

# make a k8s instance - aws centos7
Security group: default, rancher


