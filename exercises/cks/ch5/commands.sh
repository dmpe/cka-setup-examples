# 1. 
sudo kubectl run busybox-security-context --image=busybox:1.28 -o yaml --dry-run client 

# Create a Pod Security Admission (PSA) rule. 

# 2. 
sudo kubectl create ns audited

# must be correctly spelled
sudo kubectl label ns audited "pod-security.kubernetes.io/enforce=restricted"
sudo kubectl label ns audited "pod-security.kubernetes.io/enforce-version=latest"
sudo kubectl label ns audited "pod-security.kubernetes.io/warn=restricted"
sudo kubectl label ns audited "pod-security.kubernetes.io/warn-version=latest"

# 4. etcd
sudo kubectl create -n audited secret generic mysecret --from-literal=mykey=mydata

sudo ETCDCTL_API=3 etcdctl \
   --cacert=/var/lib/minikube/certs/etcd/ca.crt   \
   --cert=/var/lib/minikube/certs/etcd/server.crt \
   --key=/var/lib/minikube/certs/etcd/server.key  \
   get /registry/secrets/audited/mysecret | hexdump -C

# EDIT kuber-apiserver -> minikube will automatically restart
# no need for start/stop
