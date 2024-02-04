sudo kubectl create deployment nginx --image=nginx:1.7.0 --replicas=2
sudo kubectl scale deployment/nginx --replicas=7
sudo kubectl autoscale deployment --name nginx-hpa --cpu-percent=65 --min 3 --max 20 -o yaml > hpa.yaml
sudo kubectl rollout history deploy/nginx
sudo kubectl rollout undo deploy/nginx --to-revision=1
sudo kubectl create secret generic basic-auth --type kubernetes.io/basic-auth  --from-literal=username=super --from-literal=password=my-s8cr3t

```
    spec:
      containers:
      - image: nginx:latest
        volumeMounts:
        - mountPath: /etc/secret
          name: mysecret
          readOnly: true
      volumes:
      - name: mysecret
        secret:
          defaultMode: 420
          secretName: basic-auth

```
