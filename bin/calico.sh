#!/bin/bash

set -e

docker rm $(docker ps -a -q) || true
sudo apt purge kubelet kubeadm || true

#curl -LOJ https://github.com/kubernetes/minikube/releases/download/v1.29.0/minikube-linux-amd64
#sudo chmod +x minikube-linux-amd64
#sudo mv minikube-linux-amd64 /usr/local/bin/minikube

sudo rm -rf /etc/kubernetes/
sudo rm -rf /var/lib/kubelet/
sudo rm -rf /var/lib/minikube/
sudo rm -rf /var/lib/etcd
sudo rm -rf /etc/cni/net.d

mkdir -p /etc/cni/net.d

export CHANGE_MINIKUBE_NONE_USER=true
sudo sysctl fs.protected_regular=0

sudo -E minikube start --driver=none --container-runtime='docker' --cni="calico"


# sudo minikube addons enable dashboard
# sudo minikube addons enable ingress
# sudo minikube dashboard
