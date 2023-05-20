sudo kubectl create deployment nginx --image=nginx:1.7.0 --replicas=2
sudo kubectl scale deployment/nginx --replicas=7
sudo kubectl autoscale deployment --name nginx-hpa

3. Create a Horizontal Pod Autoscaler named nginx-hpa for the Deployment with
an average utilization of CPU to 65% and an average utilization of memory to
1Gi. Set the minimum number of replicas to 3 and the maximum number of
replicas to 20.

4. Update the Pod template of the Deployment to use the image nginx:1.21.1.
Make sure that the changes are recorded. Inspect the revision history. How many
revisions should be rendered? Roll back to the first revision.

5. Create a new Secret named basic-auth of type kubernetes.io/basic-auth.
Assign the key-value pairs username=super and password=my-s8cr3t. Mount the
Secret as a volume with the path /etc/secret and read-only permissions to the
Pods controlled by the Deployment.