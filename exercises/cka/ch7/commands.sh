sudo kubectl run tmp --image=busybox --restart=Never -it --rm \
-- wget 10.244.189.12

sudo kubectl top 

# https://github.com/bmuschko/cka-study-guide/blob/master/app-a/ch07/troubleshooting-pod/instructions.md
sudo kubectl create ns leo
sudo kubectl apply -n leo -f leo/mysql-service.yaml 
sudo kubectl apply -n leo -f leo/web-app-pod.yaml 
sudo kubectl apply -n leo -f leo/web-app-service.yaml 
sudo kubectl -n leo get all

minikube tunnel
sudo kubectl cluster-info/kubectl get nodes -o wide -> IP address:Port Nummber

-> DB_USER must be root

# https://github.com/bmuschko/cka-study-guide/tree/master/app-a/ch07/troubleshooting-deployment
sudo kubectl create ns pisces
sudo kubectl apply -f pisces/web-app-service.yaml -n pisces
sudo kubectl apply -f pisces/web-app-deployment.yaml -n pisces

-> Wrong deployment label -> must match

# https://github.com/bmuschko/cka-study-guide/blob/master/app-a/ch07/troubleshooting-service/instructions.md
sudo kubectl create ns gemini
sudo kubectl apply -n gemini -f gemini/mysql-pod.yaml -f gemini/mysql-service.yaml -f gemini/web-app-pod.yaml -f gemini/web-app-service.yaml

-> Wrong service label -> run -> app

# https://github.com/bmuschko/cka-study-guide/blob/master/app-a/ch07/troubleshooting-control-plane-node/instructions.md

sudo nano /etc/kubernetes/manifests/kube-scheduler.yaml

and remove authorization part in the yaml file path.yaml


