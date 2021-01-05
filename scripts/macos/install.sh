#!/usr/bin/env bash



set -x

shopt -s expand_aliases
alias k='kubectl'

##################################################################
# rancher server
##################################################################

brew install kubectl
brew link kubernetes-cli
brew install helm

k get node

helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install ingress-nginx stable/nginx-ingress -n ingress-nginx --wait
helm install ingress-nginx stable/nginx-ingress --wait

k create namespace cert-manager

k apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml
k label namespace cert-manager certmanager.k8s.io/disable-validation=true

helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v0.12.0
  # --set installCRDs=true

k get pods -n cert-manager
k get services -n cert-manager

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update
k create namespace cattle-system
helm install rancher rancher-stable/rancher \
  -n cattle-system \
  --set hostname=rancher.localdev

k -n cattle-system get services
k -n cattle-system get pods
k -n cattle-system get ingresses

# in my macos
sudo vi /etc/hosts
127.0.0.1   rancher.localdev

curl http://rancher.localdev








kubectl -n cattle-system patch  deployment.apps/cattle-cluster-agent --patch '{
    "spec": {
        "template": {
            "spec": {
                "hostAliases": [
                    {
                      "hostnames":
                      [
                        "rancher.localdev"
                      ],
                      "ip": "192.168.0.186"
                    }
                ]
            }
        }
    }
}'

kubectl -n cattle-system patch  daemonsets cattle-node-agent --patch '{
 "spec": {
     "template": {
         "spec": {
             "hostAliases": [
                 {
                    "hostnames":
                      [
                        "rancher.localdev"
                      ],
                    "ip": "192.168.0.186"
                 }
             ]
         }
     }
 }
}'



