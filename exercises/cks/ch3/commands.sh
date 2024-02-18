# 1 
openssl genrsa -out jill.key 2048
openssl req -new -key jill.key -out jill.csr -subj "/CN=jill/O=observer"

cat <<EOF | sudo kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: jill
spec:
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ3NUQ0NBWmtDQVFBd2JERUxNQWtHQTFVRUJoTUNRVlV4RXpBUkJnTlZCQWdNQ2xOdmJXVXRVM1JoZEdVeApEekFOQmdOVkJBY01CbEJ5WVdkMVpURVJNQThHQTFVRUNnd0liMkp6WlhKMlpYSXhFVEFQQmdOVkJBc01DRzlpCmMyVnlkbVZ5TVJFd0R3WURWUVFEREFock9ITXRhbWxzYkRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVAKQURDQ0FRb0NnZ0VCQU9nMU1BYXdFYVpBNVh6TXdETVhSNCtiMXBJWDZFRnhERlRuc09BR3NvK1ZlVmxvbEhZMwpDVmR2cFBQM0tpU0N3RmtQc0ZmUERXdmoyNWdiazJZM0ozVXoreUxOTnpyOVZDV084Mkk2QUMzY252QjFIcVV1CkVhZEwvY0pvTjZSOStlaVppMXkxR0p2dWFKeTloN205am5jSWxhVXZuZjVtNHluZkhVUGhuQkl1aTV0cWZ5cncKS0pWUWJoQk9iaHV3ZEd1RitFbldlYnBacDhkbWZabVJtajZvWkNUMnVXRnhFdWY2ZVNZZnJESVhKYmRhV0pwawpnQ1dZMDdraHI3cWhaL3pxbjBVQ3RMWWEyckdLcEhvMGtsYXVTc3J4cUtIMFgwK1RvSGJTYVc5Wk5GS3daSWZhCmhUWlkrcWRFc09kdlpuVFAxT2tJWnlHWFYxQ2dhZkFMOXQwQ0F3RUFBYUFBTUEwR0NTcUdTSWIzRFFFQkN3VUEKQTRJQkFRQTZCNkRZd0g5MXhXWTJGRkkxVzFDdktXSTVZbmQya2c1b3JxNCtqRDcwelExSFFsaEppRklxaS81bwpyaDBQZFpTSnVab01qZk85K1lEd1ZpWnRNbUZaNGFRUkwwRGhnQnZjL05UMXVHUXVSUGxmMXJFSExpdkpsQ0syCllBS0ZCbXZTTFJyWVR3SWl1QzlRUVN1UmhuaWtCYzY2MzBDSFA1VEYwYkt0bWUrdzFDQU1tdFQyOHlMS2hPenMKSFJsZFg3R3lyR01QbU1yQlVGazUwUXRCWVZRTkVrRi9lNGZxSVdDSWtRbjhhZEZhbjZabzJGU2NEcTgrRWdoUgpoZjZDbW5RdGxZL2c1eE5IVEQvQ1RtMVVjbkVKeHpVQVhHbXU2WWs0WC9tMFhsZ3VIVmQ0WDhuZU5oWndINUFvCjRtWkFEbTZKbVgvRm1JZWpHU3NSNW9CQUlVcHAKLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 8633400
  usages:
  - client auth
EOF
sudo kubectl certificate approve jill
sudo kubectl get csr jill -o json | gojq -r '.status.certificate' | base64 -d > jill.crt
sudo kubectl config set-credentials jill --client-key=jill.key --client-certificate=jill.crt --embed-certs=true
sudo kubectl config set-context jill --cluster=minikube --user=jill
sudo kubectl config use-context jill

# 2
sudo kubectl create role -n default --verb="get,list,watch" --resource pods main -o yaml --dry-run
sudo kubectl create rolebinding main-rb -n default --role main --group observer -o yaml --dryn-run

# 4 Create a Pod named service-list in the namespace t23. 
