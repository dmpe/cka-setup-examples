kubectl create ns apps
kubectl create sa api-access -n apps
kubectl create clusterrole api-clusterrole --resource=pods --verb=watch,list,get
k create clusterrolebinding api-clusterrolebinding --serviceaccount=apps:api-access --clusterrole api-clusterrole
# 3rd task
k run operator --image nginx:1.21.1 -n apps --port 80 --dry-run -o yaml
k create ns rm
k run disposable --image nginx:1.21.1 -n rm --port 80
k exec operator -it -n apps -- bash

APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)
TOKEN=$(cat ${SERVICEACCOUNT}/token)
CACERT=${SERVICEACCOUNT}/ca.crt

# Explore the API with TOKEN
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X DELETE ${APISERVER}/api/v1/pod
