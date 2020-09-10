#!/bin/bash

# make a rancher instance - aws centos7
Security group: rancher
	- 22, 80, 443

ssh -i doohee323.pem centos@13.56.231.160
sudo yum install docker -y

cat <<EOF | sudo tee /etc/docker/daemon.json
{
"group": "dockerroot"
}
EOF

sudo service docker restart


# https://rancher.com/docs/rancher/v2.x/en/installation/other-installation-methods/single-node-docker/

sudo su

docker run -d --restart=unless-stopped \
  -p 80:80 -p 443:443 \
  rancher/rancher:latest

docker ps | awk '{print $1}' | tail -n 1 | xargs docker logs -f 
docker ps | awk '{print $1}' | tail -n 1 | xargs docker stop d2cbc7a5670c

docker run -d --restart=unless-stopped --privileged \
  -p 80:80 -p 443:443 \
  -v /rancher:/var/lib/rancher \
  rancher/rancher:latest

curl https://13.56.231.160/

# make a k8s instance - aws centos7
Security group: default, rancher






