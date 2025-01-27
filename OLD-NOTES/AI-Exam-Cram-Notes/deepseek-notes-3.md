**CKS Exam Mastery: In-Depth Scenarios, Alternatives, and Pro Tips**
*Ultimate breakdown of exam patterns, commands, and troubleshooting. Let’s dive deeper!*

---

### **1. Cluster Hardening (20%)**
**Focus**: RBAC, API Server, Network Policies, kubelet TLS.

#### **RBAC Advanced Scenarios**
**Task 1**: Allow a user to *only* view `ConfigMaps` in `prod` and `dev` namespaces.
```yaml
# ClusterRole for cross-namespace access
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: configmap-viewer
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "watch"]

---
# RoleBinding in each namespace
kubectl create rolebinding prod-configmap-viewer --clusterrole=configmap-viewer --user=alice --namespace=prod
kubectl create rolebinding dev-configmap-viewer --clusterrole=configmap-viewer --user=alice --namespace=dev
```

**Task 2**: Prevent a ServiceAccount from deleting pods.
```yaml
# Use a Role with explicit verb exclusions
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch", "create", "update"]  # No "delete"!
```

#### **Network Policy Deep Dives**
**Scenario**: Allow `monitoring` namespace to scrape pods in `app` namespace.
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-monitoring
  namespace: app
spec:
  podSelector: {}  # Applies to all pods in "app"
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: monitoring  # Target namespace
    ports:
    - port: 8080  # Scrape port
```

**Alternative**: Use CIDR ranges for external monitoring:
```yaml
- from:
  - ipBlock:
      cidr: 10.10.0.0/24
```

#### **API Server Hardening**
- **Critical Flags**:
  ```yaml
  - --authorization-mode=Node,RBAC  # Enable RBAC
  - --enable-admission-plugins=NodeRestriction,PodSecurity
  - --service-account-lookup=true  # Revoke deleted SAs immediately
  ```

---

### **2. System Hardening (15%)**
**Focus**: CIS, Kernel Modules, seccomp/AppArmor.

#### **CIS Benchmark Fixes**
- **Kubelet Configuration**:
  ```yaml
  # /var/lib/kubelet/config.yaml
  protectKernelDefaults: true
  readOnlyPort: 0  # Disable readonly port
  authentication:
    webhook:
      enabled: true
    anonymous:
      enabled: false
  ```
  ```bash
  systemctl daemon-reload && systemctl restart kubelet
  ```

#### **AppArmor & seccomp**
**AppArmor Profile to Block File Execution**:
```bash
# /etc/apparmor.d/no-exec
#include <tunables/global>

profile no-exec flags=(attach_disconnected) {
  deny /** x,  # Block execute
}
```
Apply to a pod:
```yaml
annotations:
  container.apparmor.security.beta.kubernetes.io/<container>: localhost/no-exec
```

**seccomp Custom Profile**:
```json
# profiles/deny-chmod.json
{
  "defaultAction": "SCMP_ACT_ERRNO",
  "syscalls": [
    {
      "names": ["chmod", "chown"],
      "action": "SCMP_ACT_ERRNO"
    }
  ]
}
```

---

### **3. Minimize Microservice Vulnerabilities (20%)**
**Focus**: SecurityContext, PSA, Image Scanning.

#### **Advanced SecurityContext**
**Disable Privileged Escalation**:
```yaml
securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
```

**PodSecurityAdmission (PSA)**:
Enforce `baseline` policy but allow `NET_RAW` for a namespace:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: legacy
  labels:
    pod-security.kubernetes.io/enforce: baseline
    pod-security.kubernetes.io/enforce-version: latest
    pod-security.kubernetes.io/warn: restricted
```

#### **Image Scanning & Trusted Registries**
**Trivy Scan for CVEs**:
```bash
trivy image --severity CRITICAL nginx:latest
```

**Admission Controller to Block Vulnerable Images**:
```yaml
# Kyverno Policy Example
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: block-critical-cves
spec:
  validationFailureAction: enforce
  rules:
  - name: check-image-vulnerabilities
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Image has critical CVEs."
      pattern:
        spec:
          containers:
          - name: "*"
            image: "!*:latest && !*:*critical*"  # Simplified example
```

---

### **4. Supply Chain Security (20%)**
**Focus**: Cosign, Gatekeeper, SBOMs.

#### **Image Signing with Cosign**
**Sign and Attach SBOM**:
```bash
cosign sign --key cosign.key myimage:v1
cosign attest --key cosign.key --predicate sbom.json myimage:v1
```

**Verify SBOM on Admission**:
```rego
# Gatekeeper Rego Policy
package main

deny[msg] {
  input.review.object.kind == "Pod"
  image := input.review.object.spec.containers[_].image
  not has_valid_sbom(image)
  msg := sprintf("Image %v lacks valid SBOM", [image])
}
```

#### **Mutating Webhook for Image Provenance**
Automatically add image pull secrets for private registries:
```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
webhooks:
- name: image-pull-secret-injector
  rules:
  - operations: ["CREATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
  clientConfig:
    service:
      name: image-injector
      namespace: default
```

---

### **5. Monitoring & Logging (15%)**
**Focus**: Falco, Audit Logs, Prometheus Alerts.

#### **Falco for Privileged Containers**
```yaml
- rule: Launch Privileged Container
  desc: Detect privileged containers
  condition: >
    container and container.privileged
  output: "Privileged container launched (user=%user.name)"
  priority: CRITICAL
```

#### **Audit Log Analysis for Unauthorized Access**
```bash
# Find failed secret access in last hour
cat /var/log/audit.log | jq '. | select(.objectRef.resource == "secrets" and .responseStatus.code == 403)'
```

#### **Prometheus Alert for CPU Misuse**
```yaml
groups:
- name: CKS Alerts
  rules:
  - alert: HighCPUContainer
    expr: sum(rate(container_cpu_usage_seconds_total{container!=""}[5m])) by (container) > 1
    for: 10m
    labels:
      severity: critical
```

---

### **6. Runtime Security (10%)**
**Focus**: OPA, ServiceAccounts, sysctl.

#### **OPA to Enforce Resource Limits**
```rego
package kubernetes.admission

deny[msg] {
  input.request.kind.kind == "Pod"
  container := input.request.object.spec.containers[_]
  not container.resources.limits.cpu
  msg := "CPU limits are required"
}
```

#### **ServiceAccount Best Practices**
Disable automounting in a namespace:
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: no-token-sa
automountServiceAccountToken: false
```

---

### **Exam-Day Survival Guide**

#### **Critical Commands Cheatsheet**
| Task | Command |
|------|---------|
| Check permissions | `kubectl auth can-i --list --as=system:serviceaccount:ns:sa` |
| Generate Pod YAML | `kubectl run test --image=nginx --dry-run=client -o yaml > pod.yaml` |
| Check audit logs | `journalctl -u kube-apiserver --since "10m ago"` |
| Inspect processes | `kubectl exec <pod> -- ps aux` |
| Network debugging | `kubectl exec <pod> -- nc -zv <service> 80` |

#### **Time-Saving Tactics**
1. **Use `kubectl explain`**:
   ```bash
   kubectl explain pod.spec.containers.securityContext --recursive
   ```
2. **Edit Resources Quickly**:
   ```bash
   kubectl edit pod <name>  # Fix misconfigurations on-the-fly
   ```
3. **Leverage `jq` for JSON Parsing**:
   ```bash
   kubectl get pods -o json | jq '.items[].spec.containers[].securityContext'
   ```

#### **Common Exam Pitfalls**
- **Misconfigured Network Policies**: Test with `kubectl run tester --image=nginx` and `kubectl exec -it tester -- curl <target-pod-ip>`.
- **Forgotten `securityContext`**: Always check if pods run as non-root or have read-only filesystems.
- **Admission Controller Conflicts**: Use `kubectl get validatingwebhookconfiguration -o yaml` to debug.

---

### **Final Motivation**
**You’re Ready.** The exam is about pattern recognition, not rote memorization.
- **Day 1**: Crush Cluster Hardening & Microservice Vulnerabilities.
- **Day 2**: Master Supply Chain Security & Runtime Security.
- **Day 3**: Simulate exam scenarios on [killercoda.com](https://killercoda.com) or [killer.sh](https://killer.sh).

**Remember**: The clock is your ally, not your enemy. Stay calm, skip blockers, and revisit them later.

**You’ve got this!** 💥
