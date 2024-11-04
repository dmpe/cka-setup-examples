# cks-setup-examples

[Exam Examples &amp; Setup](https://gist.github.com/bakavets/05681473ca617579156de033ba40ee7a#certified-kubernetes-administrator-cka)

Some other information:
- https://docs.linuxfoundation.org/tc-docs/certification/important-instructions-cks
- Need to know 
  - https://aquasecurity.github.io/trivy/v0.49/
- https://github.com/kodekloudhub/certified-kubernetes-security-specialist-cks-course
- https://devopscube.com/cks-exam-guide-tips/
- https://www.freecodecamp.org/news/how-to-pass-the-certified-kubernetes-security-specialist-exam/#aliases

## Exam

- 10% Cluster Setup
  - Network Policies
  - CIS benchmark
  - Ingress control
  - Verify binaries
- 15% Cluster hardening
  - RBACs
- 15% System Hardening
  - OS footprint
  - least privilage
  - `AppArmor`, `seccomp`
- 20% Minimize vulnerabilities
  - k8s secrets
  - pod security standards/policies
  - pod-to-pod mTLS
  - OS level security
- 20% Supply chain security
  - base image footprint
  - image registry, sign and validate images
  - Scan with `Trivy`
- 20% Observability
  - Audit logs
  - immutability of runtimes
  - behavioral analytics/threat detection with `Falco`

## Minikube setup

```
./bin/calico.sh
sudo -E minikube start
```

## Setup Kubectl

```
export EDITOR=nano
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
```

## Setting Namespace with context

```
k config get-contexts
k config set-context minikube --namespace kube-system
```

## General tips

- Use `grep -B(efore) -A(fter)` for more content

# Cluster Setup

## Network Policies

[docs](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

- no imperative way, only declarative
- NS based approach

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-everything
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-everything
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - {}
  egress:
  - {}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  - Egress
  ingress: # allow ingress only from 172.17.0.0/16, but block 172.17.1.0/24 range OR
           # allow ingress from namespace with x=y labels OR
  - from:  # allow from pods which have role=frontend, in default NS
           # AND allows ingress only on 6379-32768
           # Reason for OR - from contains 3 blocks, if it would be only under 1 then it would have been AND
    - ipBlock:
        cidr: 172.17.0.0/16
        except:
        - 172.17.1.0/24
    - namespaceSelector:
        matchLabels:
          project: myproject
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 6379
      endPort: 32768
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/24
    ports:
    - protocol: TCP
      port: 5978
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: egress-namespaces
spec:
  podSelector:
    matchLabels:
      app: myapp
  policyTypes:
  - Egress
  egress:   # all ingress is allowed, but egress allowed only to 2 NS with specific labels !
  - to:
    - namespaceSelector:
        matchExpressions:
        - key: namespace
          operator: In
          values: ["frontend", "backend"]
---
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: allow-from-ns-netpol
  namespace: special-ns
spec:
  podSelector:{} 
  policyTypes:
  - Ingress 
  ingress: # allow from specific NS name
    - from:
      - namespaceSelector:     
          matchLabels:
            kubernetes.io/metadata.name: cks-exam
```


### Cilium Networking policies

NS `CiliumNetworkPolicy` and non-NS `CiliumClusterwideNetworkPolicy`

Level 3

```
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: "deny-all"
spec:
  endpointSelector:
    matchLabels:
      role: restricted
  egress:
  - {}
  ingress:
  - {}
---
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: "allow-all-from-frontend" # frontend can talk to all pods in the default NS
spec:
  endpointSelector:
    matchLabels:
      role: frontend
  egress:
  - toEndpoints:
    - {}
---
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: "cidr-rule"
spec:
  endpointSelector:
    matchLabels:
      app: myService
  egress:
  - toCIDR:
    - 20.1.1.1/32
  - toCIDRSet:
    - cidr: 10.0.0.0/8
      except:
      - 10.96.0.0/12
```

Level 4

```
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: "l4-rule" # rule limits all endpoints with the label app=myService to only be able to emit packets using TCP on port 80, to any layer 3 destination
spec:
  endpointSelector:
    matchLabels:
      app: myService
  egress:
    - toPorts:
      - ports:
        - port: "80"
          protocol: TCP
---
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: "icmp-rule" # rule limits all endpoints with the label app=myService to only be able to emit packets using ICMP 
                    # with type 8 and ICMPv6 with message EchoRequest, to any layer 3 destination:
spec:
  endpointSelector:
    matchLabels:
      app: myService
  egress:
  - icmps:
    - fields:
      - type: 8
        family: IPv4
      - type: EchoRequest
        family: IPv6
```


## CIS Benchmark

- Execute as job:

```
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job-master.yaml
```

Example in `kube-apiserver`:

`--kubernetes-service-node-port=31000 -> 0` (switching from NodePort to ClusterIP for k8s service)

requires also:

```
kubectl delete svc kubernetes
```

## TLS Ingress

[docs](https://kubernetes.io/docs/concepts/services-networking/ingress/)

- Create TLS cert, sign and import 

```
openssl req -noenc -new -x509 -keyout x.key -out x.crt -subj "/CN=x.tls"
kubectl create secret tls x --cert=x.crt --key=x.key
```
- adjust ingress object with `spec.tls`

```
spec:
  tls:
  - secretName: x
    hosts:
    - a.com
  rules:
    ...
```

- to test locally, find node IP, add to `/etc/hosts` file and then do `curl`

## Protect inbound K8s ports

- use firewall
- protect cloud metadata endpoints -> Network Policies
- protect GUI such as k8s dashboard with oauth2 proxy or RBAC keys

```
kubectl create sa observer-user -n kubernetes-dashboard
kubectl create clusterrole pod-reader --verb=get,list,watch --resource=deployment -o yaml --dry-run
kubectl create clusterrolebinding dash-sa --clusterrole=pod-reader --serviceaccount=kubernetes-dashboard:observer-user -o yaml --dry-run
kubectl create token observer-user -n kubernetes-dashboard --duration=0s

# for testing
kubectl create deployment deploy --image=nginx --replicas=3 -n default
```

## Verify binaries

- https://dl.k8s.io lists all hashes
- `$(cat kubectl.sha256) kubectl | sha256sum --check` for checking it
- `$(cat kubectl.sha512) kubectl | sha512sum --check` for checking it

# Cluster hardening

## Kubernetes API Server

- AuthN -> AuthZ -> Admission Controller -> Validation
- Adm. Con. verifies if request is well-formed or needs to be modified.
- Validation optional, can be in AC.
- API Server is exposed: 
  - `kubernetes.default.svc` to avoid IP for API server, e.g. from inside pod
    - its endpoint points to the IP/port
  - e.g. in pod via env variables `KUBERNETES_SERVICE_HOST` and `_PORT`
- access with client cert
- from kubeconfig extract base64 encoded values and then execute:

```
kubectl config view --raw -o json | jq -r '.clusters.[].cluster."certificate-authority-data"' | base64 -d > ca.crt
kubectl config view --raw -o json | jq -r '.users.[].user."client-certificate-data"' | base64 -d > pub.crt
kubectl config view --raw -o json | jq -r '.users.[].user."client-key-data"' | base64 -d > priv.key
curl --cacert ca.crt --cert kubernetes-admin.crt --key kubernetes-admin.key ...
```

### Restricting Access

- do not expose public k8s API server
- limit permissions via RBAC
- [add new users via client certificate](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/)

  - crete private key -> `openssl genrsa -out johndoe.key 2048`
  - create CSR from private key 
    - `openssl req -new -key johndoe.key -out johndoe.csr`
      - carefull on Common Name which should match task/username
    - `cat johndoe.csr | base64 -w 0 > johndoe-base64`
  - create and approve `CertSignReq` - Automatic Signature via K8s

    ```
    cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: johndoe
spec:
  request: .....<johndoe-base64>...
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400
  usages:
  - client auth
EOF
  kubectl certificate approve johndoe
  kubectl get csr johndoe -o jsonpath={.status.certificate} | base64 -d > johndoe.crt
    ```

  - create and approve `CertSignReq` - Manual signature via openssl

```
openssl x509 -req -in SOME.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out SOME.crt
```

  - add Role and assign Role to RB with the user
  - add to kubeconfig

  ```
  kubectl config set-credentials johndoe --client-key=johndoe.key --client-certificate=johndoe.crt --embed-certs=true
  kubectl config set-context johndoe --cluster=minikube --user=johndoe
  ```

- SA -> disable automount token in the pod
- SA token can be generated by `create token` or via k8s secret with special type and annotation

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sa-api
  namespace: k97
automountServiceAccountToken: true/false -> token in /var/run/secrets/kubernetes.io/serviceaccount/token
---
apiVersion: v1
kind: Secret
metadata:
  namespace: k97
  annotations:
    kubernetes.io/service-account.name: sa-api
type: kubernetes.io/service-account-t
```

#### From inside pod, K8s API access

```
curl -s -k -m 5 -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default/apis/apps/v1/namespaces/k97/deployments/
curl -s -k -m 5 -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default/api/v1/namespaces/extra/secret/my-secret/
```

- Update K8s frequently

on control nodes:
```
apt update
apt upgrade
kubeadm upgrade plan
kubeadm upgrade apply
systemctl restart kubelet
```

on worker nodes:
```
apt update
apt upgrade
kubeadm upgrade node
systemctl restart kubelet
```


### System Hardening

- removing packages, managing users/groups, ports, FW rules
- minimalize OS host footprint -> disable & remove not used services
- principle of least privilege
- /etc/passwd /etc/group
- adduser && `su ben` vs `su - ben`
- groupadd abc && usermod -g group username
- groupdel abc
- chown file permissions
- open ports -> netstat/ss

```
# what is running on port 6666
netstat -plnt | grep 6666
# where is the binary which runs port 6666 
ls -lh /proc/<PID>/exe
```

- Kernel Hardening with `seccomp` and `AppArmor`
- `AA` - [docs](https://gitlab.com/apparmor/apparmor/-/wikis/Documentation)
  - access control, a sec. layer between app and system functions
  - alternative to `SeLinux`
  - rules can define what app can/cannot do
  - must be loaded in AA before take effect -> on every worker node in `/etc/apparmor.d`
  - `aa-status` - and it has 2 modes: `enforce` or `complain`
    - load profile -> `apparmor_parser /etc/apparmor.d/k8s-deny-write` (enforce by default; or with `-C` for complain mode)
  - then apply security context with profile

```
<Pod Spec>
spec: 
  securityContext:
    appArmorProfile:
      type: RuntimeDefault # or on the host via Localhost
      localhostProfile: <name>
  containers: 
   ...
```

- `seccomp`: 
  - restrict calls made from userspace into kernel
  - standard folder: `/var/lib/kubelet/seccomp`, use `profiles` subfolder
  - opt-in pod-by-pod basis; default can be choosen

```
securityContext:
  seccompProfile:
    type: RuntimeDefault
```
  - or a custom version

```
securityContext:
  seccompProfile:
    type: Localhost
    localhostProfile: profiles/mkdir-violation.json
```

- use also `sysctl`:

```
securityContext:
  sysctls:
  - name: net.core.somaxconn
    value: "1024"
  - name: debug.iotrace
    value: "1"
```

### Microservice vulnerabilities

- define security settings not only on OS level, but also on container/pod level with tools such as PSA/Open Policy Agent/Kyverno
- avoid `root` in contianer because it is a root on the host too; could escape the pod, and infect the OS system

#### securityContext

- set `securityContext`, which defines privilege and ACLs for pod
  - user/group ID
  - grant some root priviledges
  - runAsNonRoot, priviledged, etc.

```
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  volumes:
  - name: sec-ctx-vol
    emptyDir: {}
  containers:
  - name: sec-ctx-demo
    image: busybox:1.28
    command: [ "sh", "-c", "sleep 1h" ]
    volumeMounts:
    - name: sec-ctx-vol
      mountPath: /data/demo
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      seLinuxOptions:
        level: "s0:c123,c456"
```

#### Pod Security Admission

[pod security admission](https://kubernetes.io/docs/concepts/security/pod-security-standards/):

- which security standard to follow
- opt in - always add 2 labels to a namespace:

```
pod-security.kubernetes.io/enforce (mode): baseline (level)
pod-security.kubernetes.io/<MODE>-version: latest
```

- label: prefix, mode (warn, audit, enforce) and level (baseline, priviledged, restricted)
- no flexibility, no customization

#### OPA 

not relevant in CKS

- open policy agent (OPA) / Gatekeeper
  - Rego language to write rules
  - gatekeeper uses OPA in k8s
  - create constraint template with Rego and constraint

#### ETCD

- all data in `etcd`
- by default not encrypted, can extract secrets

```
# extract secrets in plain text
export ETCDCTL_API=3
etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key |\
  get /registry/secrets/default/app-config
```

- always encrypt etcd DB via `EncryptionConfiguration`
- also needs to adjust kube API server with that file + `mountPaths` -> `--encryption-provider-config=/etc/kubernetes/enc/enc.yaml`
- :warning: to properly create `secret` use `echo -n xyz | base64`

```
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
    - secrets
    providers:
      - aescbc:
        keys:
          - name: key1
            secret: W68xlPT/VXcOSEZJvWeIvkGJnGfQNFpvZYfT9e+ZYuY=
      - identity: {}
```

#### Container runtime sandbox: Kata and gVisor

- Kata Containers:
  - runs containers in lightweigt VM

- `gVisor`:
  - implements linux kernel on host -> syscalls not shared anymore
  - uses `runsc` runtime -> `containerd` needs adjustments
  - define and reference runtime class
  - create pod, exec into it and run `dmesg` - see gVisor

```
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor
handler: runsc
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  runtimeClassName: gvisor
  containers:
  ....
```

- pod-to-pod mTLS
  - by default, no encryption between pods
  - mTLS allows to verify client identity
  - *alternative*: WireGuard 

### Supply Chain Security

- minimazing base image
  - avoid shell container, harder to troubleshoot
  - e.g. use alpine or distroless
- multistage approach to building images
  - separate build from runtime stage
- reduce number of layers
- secure supply chain
  - sign container images
  - use SHA256 hash digest for images
- use private container registry
- use OPA/kyverno/other policy engines


### Admission controller webhook

  - e.g. `ImagePolicyWebhook`
  - first define `/etc/kubernetes/admission-control/image-policy-webhook-admission-config.yaml`
  - create kubeconfig which points to webhook service endpoint
  - next, adjust API server
    - `--enable-admission-plugins=...ImagePolicyWebhook...`
    - `--admission-control-config-file=...file...` + volume mounts


- static analysis of docker images -> `hadolint`
- `kubesec` for YAML analysis
- use `trivy`/`bom` for docker image analysis

### Monitoring, Logging, Runtime Security

- Behaviour Analytics of VM nodes with Falco/Tetragon/Tracee
- `Falco` - host + container level activity
  - alert fires if matches specific event
  - must be on all workers in k8s cluster
  - `/etc/falco` for config directory + also need to restart falco to see new rules
  - rules consist of rule, macro and lists

```
sudo -i
falco ...
```

- use immutable containers
  - use distroless images
- `readOnlyRootFilesystem`: true
  - use `EmptryDir` for Write operations, e.g. Nginx


### Audit Logging 

[audit logs](https://kubernetes.io/docs/tasks/debug/debug-cluster/audit/)

  - audit policy yaml - 4 levels in `/etc/kubernetes/audit/policy.yaml`
  - logs in `/etc/kubernetes/audit/audit.log`
  - kube api server needs to be adjusted with `--audit-policy-file=/etc/kubernetes/audit-policy.yaml` + `mouthPaths`

- `SysCalls` - SysCall Activity Trace
  - investigate using `strace -f -p <PID>` when e.g. process in container pod


### kubelet

If systemd installation, then config is in `/var/lib/kubelet/config.yaml`, not in the `kubectl edit configmap -n kube-system kubelet-config`. 
For rolling it out, it will require `kubeadm upgrade node phase kubelet-config && systemctl restart kubelet`.
