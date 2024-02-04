sudo kubectl create ns external
sudo kubectl create deployment -n external nginx --image=nginx:latest --replicas=3 --port 80
# needs editing labels!
sudo kubectl create service -n external loadbalancer loba --tcp=80:80
sudo minikube tunnel in another window

sudo kubectl create service -n external clusterip loba-int --tcp=80:80
sudo kubectl run -n external fedora --image=fedora:38 -it -- bash
curl -v http://loba-int:80
sudo kubectl create ingress incoming -n external --default-backend="loba-int:80" --rule="/=loba-int:80"
sudo EDITOR=nano kubectl edit ingress -n external incoming
sudo kubectl attach fedora2 -c fedora2 -n external -i -t


sudo kubectl create deployment -n external echoserver --image=k8s.gcr.io/echoserver:1.10 --port 8080
sudo kubectl create service -n external clusterip echoserver --tcp=8080:8080
sudo minikube addons enable ingress

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: incoming
  namespace: external
spec:
  rules:
  - http:
      paths:
      - backend:
          service:
            name: loba-int
            port:
              number: 80
        path: /
        pathType: Prefix
      - backend:
          service:
            name: echoserver
            port:
              number: 8080
        path: /echo
        pathType: Exact
status:
  loadBalancer: {}
```


coredns rewrite not working

sudo EDITOR=nano kubectl edit configmap -n kube-system coredns

svc.cka.example.com svc.cluster.local

sudo kubectl create ns hello
sudo kubectl run testpod --rm --image=fedora:38 -it -n hello -- bash
