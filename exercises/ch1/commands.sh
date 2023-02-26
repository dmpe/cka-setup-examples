kubectl create -n apps
kubectl create sa api-access -n apps
kubectl create clusterrole api-clusterrole --resource=pod --verb=watch,list,get
k create clusterrolebinding api-clusterrolebinding --serviceaccount=api-acess:apps --clusterrole  api-clusterrole
k run operator --image nginx:1.21.1 -n apps --port 80 --expose ClusterIP
k create ns rm
k run disposable --image nginx:1.21.1 -n rm --port 80
k exec operator -it -n apps -- bash
