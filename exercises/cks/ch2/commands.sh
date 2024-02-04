




# 6
curl -LOJ https://dl.k8s.io/v1.26.1/bin/linux/amd64/kube-apiserver
curl -LOJ https://dl.k8s.io/v1.23.1/bin/linux/amd64/kube-apiserver.sha256
echo $(cat kube-apiserver.sha256) kube-apiserver | sha256sum --check