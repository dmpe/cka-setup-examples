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
export EDITOR=nano
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
k create sa test1 
kubectl create role read-only --verb=list,get,watch --resource=pods,deployments,services
kubectl create rolebinding read-only-binding --role=read-only
kubectl auth can-i --list --as johndoe
```

Roles/Bindings: per Namespace
Cluster -||-: no Namespace


```
k create role test1-role --verb=list,get,watch --resource=pods -o yaml > test-role.yaml
k create clusterrole test1-crole --verb=list,get,watch --resource=pods -o yaml > test-crole.yaml

k explain pods
k explain deployments

k create clusterrolebinding rb-role --clusterrole=test1-crole --user=admin
```

## Aggregating RBAC Roles:

Merge user facing role with custom role. => Merge rules via **label** selection.

```
aggregationRule:
  clusterRoleSelectors:
    - matchLabels:
        test1: "true"
    - matchLabels:
        test2: "true"
```

## Installing Cluster

Generally:

- control: kubeadm init
- install CNI
- worker: kubeadm join

```
sudo rm -rf /usr/local/bin/minikube
sudo ufw disable
sudo ufw enable
sudo ufw allow 6443/tcp
sudo ufw allow 2379:2380/tcp
sudo ufw allow 8443/tcp
sudo ufw allow 10248/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10259/tcp
sudo ufw allow 10257/tcp

sudo rm -rf /etc/kubernetes/
sudo rm -rf /var/lib/kubelet/
sudo rm -rf /var/lib/minikube/
sudo rm -rf /var/lib/etcd
sudo rm -rf /etc/cni/net.d

sudo kubeadm init --cri-socket=unix:///var/run/cri-dockerd.sock

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sudo kubeadm join 192.168.226.128:6443 --cri-socket=unix:///var/run/cri-dockerd.sock \
    --token snd1zk.6vq3bl2xrld1ul4s \
	--discovery-token-ca-cert-hash sha256:c4ed718851af5ad105d175224b4f9d8fc8e33e0cbf0bdfc9c83614af4c096687

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

sudo kubeadm reset --cri-socket=unix:///var/run/cri-dockerd.sock
```

## HA

- external etcd or stacked (colocated on the nodes)
- control: api server, scheduler, controller manager
- worker communicate with LoBa

## Cluster Upgrade

Control:

```
sudo apt-mark unhold kubeadm && sudo apt-get update && sudo apt-get install \
-y kubeadm=1.27.0-00 && sudo apt-mark hold kubeadm
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.27.0
sudo kubectl drain <node>
sudo apt-mark unhold kubelet kubectl && sudo apt-get update && sudo \
apt-get install -y kubelet=1.19.0-00 kubectl=1.19.0-00 && sudo apt-mark \
hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo kubectl undrain & uncordon
```

Worker:

```
sudo apt-mark unhold kubeadm && sudo apt-get update && sudo apt-get install \
-y kubeadm=1.27.0-00 && sudo apt-mark hold kubeadm
sudo kubeadm upgrade node
sudo kubectl drain <node>
sudo apt-mark unhold kubelet kubectl && sudo apt-get update && sudo \
apt-get install -y kubelet=1.19.0-00 kubectl=1.19.0-00 && sudo apt-mark \
hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo kubectl undrain & uncordon
```

## Backing up and restoring etcd

```
kubectl describe pod etcd-ubuntu -n kube-system
sudo ETCDCTL_API=3 etcdctl --endpoints=https://192.168.226.128:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /opt/etcd-backup.db
sudo ETCDCTL_API=3 etcdctl --endpoints=https://192.168.226.128:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--data-dir=/var/lib/from-backup \
snapshot restore /opt/etcd-backup.db
```

## Exercises 2 

See `exercices/ch2/` 

## Exercises 3

See `exercices/ch3/`

- Only deployment, Pod, and replicasets
  - Deployment with 3 Replicas = ReplicaSet with 3 Pods
  - Deployment is abstraction to manage ReplicaSets
  - `spec.selector.matchLabels` and `spec.template.metadata.labels` need to match !
- Rollout Strategy and Rollbacks
  - `kubectl rollout status deployment`
  - keeps track of changes, via revision
  - rollback: `kubectl rollout undo deployment`
- Autoscalling
  - replicas: X
  - for deployment: `kubectl scale deployment/statefulset`
  - `Horizontal Pod Autoscaler`: `kubectl autoscale deployment app-cache --cpu-percent=80 --min=3 --max=5/kubectl get hpa`
  - pods needs to have ressources section 
- ConfigMap
  - either as env or mounted as volume; always in RAM
  - ENV: 
    ```    
    envFrom:
    - configMapRef: 
        name: <name>`
    ```
  - Volume: 
    ```
      volumeMounts:
      - name: db-config-volume
        mountPath: /etc/config
    volumes:
    - name: db-config-volume
      configMap:
        name: db-config
    ```
- Secret
  - types: generic, TLS, docker-registry
  - `data` needs base64 values, `stringData` only cleartext
  - ENV: 
    ```    
    envFrom:
    - secretRef: 
        name: <name>`
    ```
  - Volumes:
  ```
  ...
    volumes:
    - name: db-config-volume
      secret:
        secretName: db-config
  ```
## Exercises 4

- Resources and Limits
  - if only limits specified, then limits==resources

## Exercises 5

CNI

- Connectivity between Containers (1 Pod)
  - 1 pod => 1 IP = N containers who share same IP and port space
  - can communicate using localhost -> sidecars
- Connectivity between Pods 
  - each node gets dedicated subnet 
  - IP to pod is unique, across nodes & NS
  - IPs are not stable -> pod restart = new IP
- K8s Service
  - discoverable names and LoBa
  - works on basis of labels
  - types: clusterIP (default), NodePort, LoadBalancer (cloud only)
      - imperative: `kubectl create service <type> <name> --tpc=<exposed port>:<target port>`
      - `kubectl run ... --expose` also creates service
  - NodePort: open port on each node in cluster, globally unique at cluster level
- Ingress
  - LoBa Level 7 -> to Service
- CoreDNS
  - maps name of service to IP address
  - defines cluster domain, default: cluster.local
  - customize via new configMap called `coredns-custom`
  - either just service `name:port` or if NSed then e.g. `service name.<NS>.cluster.local.svc:port`
  - Resolve by Pod IP: replace `.` with `-`, e.g. `172-17-0-8.ns1.pod:8080`
  
  
  
  
  
