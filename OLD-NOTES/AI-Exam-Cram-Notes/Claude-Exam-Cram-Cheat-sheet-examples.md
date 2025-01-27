# 🔒 CKS (Certified Kubernetes Security Specialist) Detailed Exam Cram Sheet

## 1. Cluster Security Assessment

### CIS Benchmarks
```bash
# Run kube-bench for master node
kube-bench run --targets master

# Run for worker nodes
kube-bench run --targets node

# Check specific test
kube-bench run --check 1.2.1
```

### Common Fixes for CIS Issues
```yaml
# API Server config (/etc/kubernetes/manifests/kube-apiserver.yaml)
spec:
  containers:
  - command:
    - kube-apiserver
    - --encryption-provider-config=/etc/kubernetes/encryption/encryption-config.yaml
    - --audit-log-path=/var/log/kubernetes/audit.log
    - --audit-policy-file=/etc/kubernetes/audit-policy.yaml
    - --audit-log-maxage=30
    - --insecure-port=0  # Disable insecure port
```

## 2. ETCD Security

### Encryption at Rest
```yaml
# /etc/kubernetes/encryption/encryption-config.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
    - secrets
    providers:
    - aescbc:
        keys:
        - name: key1
          secret: <32-byte-key>
    - identity: {}
```

### Client Certificate Authentication
```bash
# Generate client cert
openssl genrsa -out client.key 2048
openssl req -new -key client.key -subj "/CN=client" -out client.csr
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt
```

## 3. RBAC Configuration

### Create Role
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

### Create RoleBinding
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### Quick RBAC Verification
```bash
# Test permissions
kubectl auth can-i get pods --as jane
kubectl auth can-i create deployments --as system:serviceaccount:default:myapp
```

## 4. Network Policies

### Default Deny All
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### Allow Specific Traffic
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

## 5. Runtime Security

### AppArmor Profile
```bash
# Load AppArmor profile
apparmor_parser -r /etc/apparmor.d/container-profile

# Apply to pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  annotations:
    container.apparmor.security.beta.kubernetes.io/nginx: localhost/custom-profile
```

### Falco Rules
```yaml
# Custom rule
- rule: Unauthorized Process Started
  desc: Detect unauthorized process execution
  condition: spawned_process and not proc.name in (allowed_processes)
  output: Unauthorized process started (user=%user.name command=%proc.cmdline)
  priority: WARNING
```

## 6. Supply Chain Security

### Image Scanning
```bash
# Scan with Trivy
trivy image nginx:1.19
trivy image --severity HIGH,CRITICAL nginx:1.19

# Save results
trivy image -f json -o results.json nginx:1.19
```

### ImagePolicyWebhook Configuration
```yaml
apiVersion: v1
kind: Config
plugins:
- name: ImagePolicyWebhook
  configuration:
    imagePolicy:
      kubeConfigFile: /etc/kubernetes/webhook/kubeconfig.yaml
      allowTTL: 50
      denyTTL: 50
      retryBackoff: 500
      defaultAllow: false
```

## 7. Secret Management

### Create and Use Secrets
```bash
# Create from literal
kubectl create secret generic db-creds \
  --from-literal=username=admin \
  --from-literal=password=s3cr3t

# Create from files
kubectl create secret generic tls-certs \
  --from-file=private.key \
  --from-file=certificate.crt
```

### Mount Secrets in Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: secrets
      mountPath: "/etc/secrets"
      readOnly: true
  volumes:
  - name: secrets
    secret:
      secretName: db-creds
```

## 8. Audit Logging

### Audit Policy
```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
  resources:
  - group: ""
    resources: ["pods"]
- level: RequestResponse
  resources:
  - group: "authentication.k8s.io"
    resources: ["*"]
```

## Quick Reference Commands
```bash
# Certificate Management
openssl x509 -in cert.crt -text -noout  # View certificate
openssl verify -CAfile ca.crt cert.crt   # Verify certificate

# Context/User Management
kubectl config set-credentials user --client-certificate=user.crt --client-key=user.key
kubectl config set-context user-context --cluster=cluster-name --user=user

# Security Context
kubectl create deployment secure-nginx --image=nginx --dry-run=client -o yaml > deploy.yaml
# Then add:
securityContext:
  runAsUser: 1000
  runAsGroup: 3000
  fsGroup: 2000
```

## Exam Tips
1. Always verify configurations:
   ```bash
   kubectl get networkpolicy
   kubectl describe networkpolicy
   kubectl get pods -o yaml | grep securityContext
   ```

2. Check logs for troubleshooting:
   ```bash
   kubectl logs pod-name
   journalctl -u kubelet
   ```

3. Common Locations:
   - Manifests: `/etc/kubernetes/manifests/`
   - Certificates: `/etc/kubernetes/pki/`
   - Audit logs: `/var/log/audit/`
   - kubeconfig: `/etc/kubernetes/admin.conf`

Remember to:
- Start with CIS benchmark scanning
- Implement network policies first
- Verify RBAC configurations
- Check container security contexts
- Monitor audit logs for issues

This should give you a solid foundation for the exam. Focus on practicing these commands and configurations in a test environment before the exam.
