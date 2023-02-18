# cka-setup-examples

[CKA Exam Examples &amp; Setup](https://gist.github.com/bakavets/05681473ca617579156de033ba40ee7a#certified-kubernetes-administrator-cka)


## Exam

- 25 Cluster Arch, Installation, Config
  - RBAC, KubeADM
  - Upgrade
  - etcd backup and restore
- 15 Workloads and Scheduling
  - Rolling update, Rollbacks
  - Config and Secret
  - Limits
- 20 Services and Networking
  - Connectivity between pods
  - LoBa, ClusterIP, NodePort
  - Ingress, CoreDNS
- 10 Storage
  - Storage Class, PV, PVC
  - Volume Mode, Access Mode, Reclaim policy
- 30 Troubleshooting
  - Logging
  - Node, Networking

## Minikube setup

```
./bin/calico.sh
sudo -E minikube start
```

## Setup Kubectl

```
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
```

## Setting Namespace with context

```
k config get-contexts
k config set-context minikube --namespace kube-system
```

## RBAC

- Subject: Users, Groups, ServiceAccount
- API Resources: Pod, Deployment, etc.
- Operations: Create, List, Watch

```
k create role test1-role --verb=list,get,watch --resource=pods -o yaml > test-role.yaml
k create clusterrole test1-crole --verb=list,get,watch --resource=pods -o yaml > test-crole.yaml

k explain pods
k explain deployments

k create clusterrolebinding rb-role --clusterrole=test1-crole --user=admin
```

TODO:
- Aggregated Roles

## Installing Cluster

Generally:

- control: kubeadm init
- install CNI
- worker: kubeadm join

```
sudo ufw allow 6443/tcp
sudo ufw allow 2379:2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10259/tcp
sudo ufw allow 10257/tcp

sudo rm -rf /etc/kubernetes/
sudo rm -rf /var/lib/kubelet/
sudo rm -rf /var/lib/etcd
sudo rm -rf /etc/cni/net.d

sudo kubeadm init --cri-socket=unix:///var/run/cri-dockerd.sock
sudo kubeadm reset --cri-socket=unix:///var/run/cri-dockerd.sock

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

```


