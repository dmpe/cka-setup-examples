sudo kubectl --kubeconfig ~/.kube/config ...


# 4
sudo kubectl create sa observer-user -n kubernetes-dashboard
sudo kubectl create clusterrole pod-reader --verb=get,list,watch --resource=deployment -o yaml --dry-run
sudo kubectl create deployment deploy --image=nginx --replicas=3 -n default
sudo kubectl create clusterrolebinding dash-sa --clusterrole=pod-reader --serviceaccount=kubernetes-dashboard:observer-user -o yaml --dry-run
sudo kubectl create token observer-user -n kubernetes-dashboard --duration=0s

sudo kubectl port-forward -n kubernetes-dashboard pods/kubernetes-dashboard-8694d4445c-qwrhb 8080:9090


# 6
curl -LOJ https://dl.k8s.io/v1.26.1/bin/linux/amd64/kube-apiserver
curl -LOJ https://dl.k8s.io/v1.23.1/bin/linux/amd64/kube-apiserver.sha256
echo $(cat kube-apiserver.sha256) kube-apiserver | sha256sum --check

