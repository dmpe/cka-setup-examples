#!/bin/bash

set -e

export CHANGE_MINIKUBE_NONE_USER=true
sudo sysctl fs.protected_regular=0

sudo -E minikube start --driver=none --container-runtime='docker' --cni="calico"



# sudo minikube addons enable dashboard
# sudo minikube addons enable ingress

# sudo minikube dashboard
