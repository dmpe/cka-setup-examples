#!/bin/bash
set -e
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

k3s server -c ../etc/config.yaml
sudo chown $USER:$USER /etc/rancher/k3s/k3s.yaml
# sudo kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml
# sudo kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/custom-resources.yaml
# sudo /usr/local/bin/k3s-uninstall.sh