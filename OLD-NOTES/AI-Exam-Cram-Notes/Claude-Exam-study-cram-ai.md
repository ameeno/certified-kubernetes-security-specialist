# 🚀 CKS Exam Cram Guide (3-Day Intensive)

## Day 1: Core Security Fundamentals

### 1. Cluster Hardening Basics

#### ETCD Encryption
```yaml:/Users/arun/Code/cks-lab/certified-kubernetes-security-specialist/examples/encryption-config.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
    - secrets
    providers:
    - aescbc:
        keys:
        - name: key1
          secret: <base64-encoded-32-bytes-key>
    - identity: {}
```

Enable it:
```bash
# Generate encryption key
head -c 32 /dev/urandom | base64

# Add to kube-apiserver.yaml
--encryption-provider-config=/etc/kubernetes/encryption/encryption-config.yaml
```

#### API Server Security
```bash
# Secure API server
kubectl edit cm -n kube-system kube-apiserver
```

Key configurations:
```yaml
--secure-port=6443
--insecure-port=0
--audit-log-path=/var/log/kubernetes/audit.log
--authorization-mode=Node,RBAC
```

### 2. Authentication & Authorization

#### Certificate Creation
```bash
# Create private key
openssl genrsa -out john.key 2048

# Create CSR
openssl req -new -key john.key -subj "/CN=john/O=developers" -out john.csr

# Sign certificate
openssl x509 -req -in john.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out john.crt -days 365
```

#### RBAC Example
```yaml:/Users/arun/Code/cks-lab/certified-kubernetes-security-specialist/examples/developer-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: development
  name: developer
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "create"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "create"]
```

```yaml:/Users/arun/Code/cks-lab/certified-kubernetes-security-specialist/examples/role-binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-binding
  namespace: development
subjects:
- kind: User
  name: john
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

## Day 2: System & Workload Hardening

### 1. Network Policies

```yaml:/Users/arun/Code/cks-lab/certified-kubernetes-security-specialist/examples/restrict-traffic.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-allow
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
```

### 2. Pod Security Context

```yaml:/Users/arun/Code/cks-lab/certified-kubernetes-security-specialist/examples/secure-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - name: app
    image: nginx
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

### 3. Runtime Security

```yaml:/Users/arun/Code/cks-lab/certified-kubernetes-security-specialist/examples/falco-rule.yaml
- rule: Unauthorized Process Started
  desc: Detect unauthorized process execution
  condition: spawned_process and not proc.name in (allowed_processes)
  output: "Warning unauthorized process started: %proc.cmdline"
  priority: WARNING
```

## Day 3: Supply Chain Security & Monitoring

### 1. Image Scanning
```bash
# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.18.3

# Scan image
trivy image nginx:1.19
```

### 2. Secure Supply Chain
```yaml:/Users/arun/Code/cks-lab/certified-kubernetes-security-specialist/examples/image-policy.yaml
apiVersion: v1
kind: Config
plugins:
- name: ImagePolicyWebhook
  configuration:
    imagePolicy:
      kubeConfigFile: /etc/kubernetes/webhook/kubeconfig.yaml
      defaultAllow: false
```

### 3. Audit Logging
```yaml:/Users/arun/Code/cks-lab/certified-kubernetes-security-specialist/examples/audit-policy.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
  resources:
  - group: ""
    resources: ["pods", "services"]
- level: RequestResponse
  resources:
  - group: "authentication.k8s.io"
    resources: ["*"]
```

## Quick Reference Commands
```bash
# CIS Benchmark
kube-bench run --targets master
kube-bench run --targets node

# Certificate Management
kubectl config set-credentials john --client-certificate=john.crt --client-key=john.key
kubectl config set-context john-context --cluster=kubernetes --user=john

# Network Policy Testing
kubectl run test-pod --image=busybox -- sleep 3600
kubectl exec test-pod -- wget -qO- http://service-ip:port

# Security Context Verification
kubectl exec pod-name -- id
kubectl exec pod-name -- mount | grep /
```

## 🎯 Exam Strategy
1. Read question carefully
2. Start with easy tasks
3. Use `kubectl explain` for resource details
4. Always verify your work
5. Save complex monitoring tasks for last

## 💪 You've Got This!
- Focus on hands-on practice
- Understand the concepts, don't just memorize
- Use `kubectl explain` and `--help`
- Practice time management
- Stay calm and methodical

Remember: The exam is about practical security implementation. Focus on understanding the "why" behind each security measure. You can do this! 🚀

Need more specific examples for any topic? Just ask! Good luck with your preparation! 💪
