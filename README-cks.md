# cka-setup-examples

[Exam Examples &amp; Setup](https://gist.github.com/bakavets/05681473ca617579156de033ba40ee7a#certified-kubernetes-administrator-cka)

Some other information:
- https://docs.linuxfoundation.org/tc-docs/certification/important-instructions-cks
- Need to know 
  - https://aquasecurity.github.io/trivy/v0.49/
- https://github.com/kodekloudhub/certified-kubernetes-security-specialist-cks-course
- https://devopscube.com/cks-exam-guide-tips/
- https://www.freecodecamp.org/news/how-to-pass-the-certified-kubernetes-security-specialist-exam/#aliases

## Exam

- 10% CLuster Setup
  - NetPolicies
  - CIS benchmark
  - Ingress control
  - Verify binaries
- 15% Cluster hardening
  - RBACs
- 15% System Hardening
  - OS footprint
  - least privilage
  - AppArmor, seccomp
- 20% Minimize vulnerabilities
  - k8s secrets
  - pod-to-pod mTLS
  - OS level security
- 20% Supply chain security
  - base image footprint
  - image registry, sign and validate images
  - Scan with Trivy
- 20% Observability
  - Audit logs
  - immutability of runtimes
  - behavioral analytics/threat detection

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

## Network Policies

- no imperative way, only declarative
- NS based approach

## CIS Benchmark

- Execute as job

```
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/\
main/job-master.yaml
```

## TLS Ingress

- Create TLS cert, sign and import 

```
openssl req -nodes -new -x509 -keyout x.key -out x.crt -subj "/CN=x.tls"
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
- protect GUI such as k8s dashboard with oauth2 proxy

## Verify binaries

- https://dl.k8s.io lists all hashes
- `$(cat kubectl.sha256) kubectl | sha256sum --check` for checking it







