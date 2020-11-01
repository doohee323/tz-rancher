#!/usr/bin/env bash

#https://rancher.com/docs/rancher/v2.x/en/installation/other-installation-methods/single-node-docker/

##################################################################
# rancher server
##################################################################
# aws: ssh -i ~/.ssh/dewey_ca1.pem centos@54.67.120.201
# linode: ssh -i ~/.ssh/doohee323 root@45.79.109.174

## 1) open ports
# all ports: https://rancher.com/docs/rancher/v2.x/en/installation/requirements/ports/
#add rancher1 security group
#open tcp 22, 80, 443, 2379, 6443, 10250 inbound 
#open udp 8472 inbound 

sudo su

## 2) install docker
yum install docker -y

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "group": "root"
}
EOF

sudo service docker restart
sudo systemctl enable docker

useradd centos
echo "centos" | passwd --stdin centos
sudo usermod -aG dockerroot centos

sudo groupadd docker
sudo usermod -aG docker centos

#add /etc/sudoers
cat <<EOF | sudo tee /etc/sudoers.d/rancher
centos ALL=(ALL) NOPASSWD:ALL
EOF

## 3) install rancher
docker run -d --restart=unless-stopped \
  -p 80:80 -p 443:443 \
  --privileged \
  rancher/rancher:latest

docker ps | grep 'rancher/rancher' | awk '{print $1}' | xargs docker logs -f

curl http://54.183.236.40

## 4) install rke

#sudo service docker restart

yum install wget -y
wget https://github.com/rancher/rke/releases/download/v1.2.1/rke_linux-amd64
mv rke_linux-amd64 /usr/bin/rke
chmod 755 /usr/bin/rke
rke -v

## open ports in master
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=8472/udp
firewall-cmd --add-masquerade --permanent
# only if you want NodePorts exposed on control plane IP as well
firewall-cmd --permanent --add-port=30000-32767/tcp
systemctl restart firewalld

## 5) rke config (with centos account)
sudo chown -Rf centos:centos /home/centos/.ssh
su - centos
mkdir /home/centos/.ssh
# copy from mine /Users/dhong/.ssh/doohee323
# scp -i ~/.ssh/dewey_ca1.pem /Users/dhong/.ssh/doohee323 centos@54.67.120.201:/home/centos/.ssh/id_rsa
# scp -i ~/.ssh/doohee323 /Users/dhong/.ssh/doohee323 root@45.79.109.174:/home/centos/.ssh/id_rsa
ll /home/centos/.ssh/id_rsa

cd /home/centos/.ssh
sudo chown centos:centos id_rsa
sudo chmod 600 id_rsa
eval `ssh-agent`
ssh-add id_rsa

# add authorized_keys in k8s host from /Users/dhong/.ssh/doohee323.pub
sudo chmod 700 /home/centos/.ssh
sudo chmod 640 /home/centos/.ssh/authorized_keys

#ssh 13.56.229.79
##ssh 45.79.225.66
#ssh 45.79.78.194
#Are you sure you want to continue connecting (yes/no)? yes

# check access is ok
#ssh -i ~/.ssh/id_rsa centos@13.56.229.79
#ssh -i ~/.ssh/id_rsa centos@45.79.225.66
#ssh -i ~/.ssh/id_rsa centos@96.126.102.140

cd /home/centos

$# 6) Add k8s host into rancher
rke config    ## host -> k8s host
[+] Cluster Level SSH Private Key Path [~/.ssh/id_rsa]:
[+] Number of Hosts [1]:
[+] SSH Address of host (1) [none]: 45.79.109.174
[+] SSH Port of host (1) [22]:
[+] SSH Private Key Path of host (45.79.109.174) [none]: /home/centos/.ssh/id_rsa
[+] SSH User of host (45.79.109.174) [ubuntu]: centos
[+] Is host (45.79.109.174) a Control Plane host (y/n)? [y]:
[+] Is host (45.79.109.174) a Worker host (y/n)? [n]: y
[+] Is host (45.79.109.174) an etcd host (y/n)? [n]: y
[+] Override Hostname of host (45.79.109.174) [none]:
[+] Internal IP of host (45.79.109.174) [none]:
[+] Docker socket path on host (45.79.109.174) [/var/run/docker.sock]:
[+] Network Plugin Type (flannel, calico, weave, canal) [canal]:
[+] Authentication Strategy [x509]:
[+] Authorization Mode (rbac, none) [rbac]:
[+] Kubernetes Docker image [rancher/hyperkube:v1.19.3-rancher1]:
[+] Cluster domain [cluster.local]:
[+] Service Cluster IP Range [10.43.0.0/16]:
[+] Enable PodSecurityPolicy [n]:
[+] Cluster Network CIDR [10.42.0.0/16]:
[+] Cluster DNS Service IP [10.43.0.10]:
[+] Add addon manifest URLs or YAML files [no]:

ll cluster.yml

## 7) rke up (with centos account)
sudo chown -Rf centos:centos /var/run/docker.sock
docker ps
rm -Rf cluster.rkestate
rm -Rf kube_config_cluster.yml
rke up

ll kube_config_cluster.yml

## rancher clean up
#https://github.com/rancher/rancher/blob/master/cleanup/user-cluster.sh
#./user-cluster.sh rancher/rancher-agent:<RANCHER_VERSION>
#docker container kill $(docker ps -q)
#docker container rm $(docker ps -a -q) -f
#docker image rm $(docker images -a -q)

## 8) install kubectl
sudo su
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubectl

## 9) import a cluster
## from Import Cluster page
## 1. create a cluster
##    Add Cluster > Other Cluster > Cluster Name: jenkins
## 2. import cluster
## https://54.183.236.40/g/clusters/add/launch/import?importProvider=other
## add "--kubeconfig=kube_config_cluster.yml"
su - centos
curl --insecure -sfL https://54.67.120.201/v3/import/jr6dnhn9j8srfnlrbkbpbjl5284cstctxcfhj9fwk8wdk7jcsdhrpd.yaml | kubectl apply --kubeconfig=kube_config_cluster.yml -f -
curl --insecure -sfL https://45.79.109.174/v3/import/7gj274nh5wkqszw2bprg8gh27bs7jbldsz4nhpqj2dcgtfhtd87kqd.yaml | kubectl apply --kubeconfig=kube_config_cluster.yml -f -

firewall-cmd --permanent --add-port=2376/tcp
firewall-cmd --permanent --add-port=9099/tcp
firewall-cmd --permanent --add-port=10254/tcp
systemctl restart firewalld


##################################################################
# k8s host
##################################################################
# aws: ssh -i ~/.ssh/dewey_ca1.pem centos@3.101.86.94
ssh -i ~/.ssh/dewey_ca1.pem centos@54.193.16.121
# linode: ssh -i ~/.ssh/doohee323 root@96.126.102.140
ssh -i ~/.ssh/doohee323 root@45.79.78.194
sudo su
yum install docker -y

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "group": "root"
}
EOF

sudo service docker restart
sudo systemctl enable docker

useradd centos
echo "centos" | passwd --stdin centos
sudo usermod -aG dockerroot centos

#add /etc/sudoers
cat <<EOF | sudo tee /etc/sudoers.d/rancher
centos ALL=(ALL) NOPASSWD:ALL
EOF

## worker node
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=8472/udp
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --add-masquerade --permanent
systemctl restart firewalld

firewall-cmd --permanent --add-port=2376/tcp
firewall-cmd --permanent --add-port=9099/tcp
firewall-cmd --permanent --add-port=10254/tcp
systemctl restart firewalld

# add authorized_keys from /Users/dhong/.ssh/doohee323.pub
su - centos
sudo mkdir /home/centos/.ssh
sudo chown -Rf centos:centos /home/centos/.ssh
sudo chmod 700 /home/centos/.ssh
sudo chmod 640 /home/centos/.ssh/authorized_keys

sudo chown -Rf centos:centos /var/run/docker.sock
docker ps


########################################################
# jenkins in k8s
########################################################
#https://phoenixnap.com/kb/how-to-install-jenkins-kubernetes

## deploy jenkins server
# https://54.67.120.201/p/c-9t7lz:p-9vgpr/workloads
#cf. docker run -v jenkins_home:/var/jenkins_home -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts

# 1) make a jenkins image and push to dockerhub
su - centos
mkdir /home/centos/jenkins-master
cat <<EOF | sudo tee /home/centos/jenkins-master/Dockerfile
FROM jenkins/jenkins:lts
VOLUME /var/jenkins_home
USER jenkins
EOF

cd /home/centos/jenkins-master
docker build -t doohee323/jenkins-master ./
export DOCKER_ID=doohee323
export DOCKER_PASSWD=
docker login -u="$DOCKER_ID" -p="$DOCKER_PASSWD"
docker images
docker push doohee323/jenkins-master

# make a test image and push to dockerhub
mkdir /home/centos/jenkins-slave
cat <<EOF | sudo tee /home/centos/jenkins-slave/Dockerfile
FROM jenkins/jnlp-slave
ENTRYPOINT ["jenkins-slave"]
EOF

cd /home/centos/jenkins-slave
docker build -t doohee323/jenkins-slave ./
docker push doohee323/jenkins-slave

## 2) import in workloads
# import YAML
# https://45.79.109.174/p/c-5p2sg:p-dv8kc/workloads

vi jenkins_deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      containers:
      - name: jenkins
        image: doohee323/jenkins-master
        env:
          - name: JAVA_OPTS
            value: -Djenkins.install.runSetupWizard=false
        ports:
          - name: http-port
            containerPort: 8080
          - name: jnlp-port
            containerPort: 50000
        volumeMounts:
          - name: jenkins-home
            mountPath: /var/jenkins_home
      volumes:
        - name: jenkins-home
          emptyDir: {}

vi jenkins_service.yaml
apiVersion: v1
kind: Service
metadata:
  name: jenkins
spec:
  type: NodePort
  ports:
    - port: 8080
      targetPort: 8080
  selector:
    app: jenkins


## 3) make a secret key
https://45.79.109.174/apikeys
Add key >
Access Key (username):  token-rrrmx
Secret Key (password):: txh2768q5tlm9l2v67fsgpfpt6jm52c74zww5slsgltq7b2lcgn67p

## 4) get jenkins url
kubectl get nodes
NAME             STATUS   ROLES                      AGE   VERSION
96.126.102.140   Ready    controlplane,etcd,worker   15m   v1.19.3

kubectl get all | grep service/jenkins
service/jenkins      NodePort    10.43.156.129   <none>        8080:31483/TCP   32s

=> http://96.126.102.140:31483

## 5) install jenkins plugins
http://96.126.102.140:31483/pluginManager/available
install kubernetes and green balls

#kubectl create clusterrolebinding jenkins --clusterrole cluster-admin --serviceaccount=jenkins:default
#kubectl run -it --rm --restart=Never busybox --image=busybox:1.28 -- nslookup kubernetes.default
#kubernetes Url: https://kubernetes.default.svc.cluster.local

## 6) setting kubernetes plugin
http://96.126.102.140:31483/configureClouds/

#kubectl cluster-info
Kubernetes Url: https://45.79.109.174
Disable https certificate check: check
Kubernetes Namespace: default
Credentials: token-rrrmx / txh2768q5tlm9l2v67fsgpfpt6jm52c74zww5slsgltq7b2lcgn67p
kubectl describe services/jenkins | grep IP
IP:                       10.43.156.129
Jenkins URL: http://10.43.156.129

Pod Templates: jenkins
    Containers: slave1
    Docker image: doohee323/jenkins-slave

## 7) make a job
job name: slave1
build > execute shell: echo "i am slave1"; sleep 60







