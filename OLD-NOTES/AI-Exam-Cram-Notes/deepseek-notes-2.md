**CKS Exam Deep Dive: Comprehensive Examples & Alternatives**
*Focus on patterns, not memorization. You’ll see variations of these tasks!*

---

### **1. Cluster Hardening (20%)**
**Key Tasks**: RBAC, API Server Security, Network Policies, TLS for kubelet.

#### **RBAC**:
**Scenario**: Create a role that allows *only* updating deployments in `dev` namespace.
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deploy-updater
  namespace: dev
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["patch", "update"]  # Least privilege!
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-updater-binding
  namespace: dev
subjects:
- kind: User
  name: john
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: deploy-updater
  apiGroup: rbac.authorization.k8s.io
```
**Alternatives**:
- Use **ClusterRole** for cluster-wide access (e.g., `nodes` resource).
- Bind ServiceAccount to a Role for pods:
  ```bash
  kubectl create rolebinding dev-sa-binding --role=deploy-updater --serviceaccount=dev:default
  ```

#### **Network Policies**:
**Scenario**: Allow ingress from `frontend` pods to `backend` pods on port 5432.
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-allow-frontend
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
      port: 5432
```
**Alternatives**:
- Block all egress:
  ```yaml
  policyTypes: [Egress]
  egress: []  # No allowed egress = block all
  ```
- Allow traffic from specific CIDR:
  ```yaml
  - from:
    - ipBlock:
        cidr: 192.168.1.0/24
  ```

#### **API Server Flags**:
- **Disable anonymous access**:
  ```yaml
  # /etc/kubernetes/manifests/kube-apiserver.yaml
  - --anonymous-auth=false
  ```
- **Enable audit logging**:
  ```yaml
  - --audit-policy-file=/etc/kubernetes/audit-policy.yaml
  - --audit-log-path=/var/log/apiserver/audit.log
  ```

---

### **2. System Hardening (15%)**
**Key Tasks**: CIS Benchmarks, Kernel Modules, seccomp/AppArmor.

#### **CIS Benchmark Fixes**:
- **Disable `--anonymous-auth` for kubelet**:
  ```bash
  # Edit /var/lib/kubelet/config.yaml
  authentication:
    anonymous:
      enabled: false
  systemctl restart kubelet
  ```

#### **AppArmor**:
**Example Profile**:
```bash
# /etc/apparmor.d/nginx-deny-write
#include <tunables/global>

profile nginx-deny-write flags=(attach_disconnected) {
  # Deny all file writes
  deny /** w,
}
```
Load and apply:
```bash
apparmor_parser /etc/apparmor.d/nginx-deny-write
```
```yaml
# Pod manifest
annotations:
  container.apparmor.security.beta.kubernetes.io/<container-name>: localhost/nginx-deny-write
```

**Alternative to seccomp**: Use runtime default profile:
```yaml
securityContext:
  seccompProfile:
    type: RuntimeDefault
```

---

### **3. Minimize Microservice Vulnerabilities (20%)**
**Key Tasks**: SecurityContext, PodSecurityAdmission, Image Scanning.

#### **SecurityContext Examples**:
**Restrict Capabilities**:
```yaml
containers:
- name: secured
  image: nginx
  securityContext:
    capabilities:
      drop: ["ALL"]
      add: ["NET_BIND_SERVICE"]  # Only what's needed
```

**Read-Only Root Filesystem**:
```yaml
securityContext:
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
volumeMounts:
- name: tmp
  mountPath: /tmp
volumes:
- name: tmp
  emptyDir: {}
```

#### **PodSecurityAdmission (PSA)**:
**Enforce `restricted` policy in namespace**:
```bash
kubectl label ns dev pod-security.kubernetes.io/enforce=restricted
```
**PSA Levels**:
- `privileged`: No restrictions.
- `baseline`: Prevent known privilege escalations.
- `restricted`: Strict (e.g., requires `runAsNonRoot`).

---

### **4. Supply Chain Security (20%)**
**Key Tasks**: Image Signing, Admission Control, Verify Image Provenance.

#### **Cosign & OPA Gatekeeper**:
**Sign and Verify**:
```bash
cosign sign --key cosign.key myimage:v1
cosign verify --key cosign.pub myimage:v1
```

**Gatekeeper Policy to Require Signed Images**:
```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredImageChecksum
metadata:
  name: require-signed-images
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
  parameters:
    keys:
      - name: mykey
        publicKey: |
          -----BEGIN PUBLIC KEY-----
          ...
          -----END PUBLIC KEY-----
```

---

### **5. Monitoring & Logging (15%)**
**Key Tasks**: Falco Alerts, Audit Log Analysis, Prometheus Rules.

#### **Falco Custom Rule**:
```yaml
- rule: Write to Sensitive Directory
  desc: Detect writes to /etc
  condition: >
    container and proc.name != "systemd" and
    (fd.directory = "/etc" and evt.type = write)
  output: "File modified in /etc (user=%user.name command=%proc.cmdline)"
  priority: CRITICAL
```

#### **Audit Log Analysis**:
Find unauthorized access to secrets:
```bash
grep "secrets" /var/log/apiserver/audit.log | grep "ResponseStatus":\{"code":403
```

---

### **6. Runtime Security (10%)**
**Key Tasks**: ServiceAccount Restrictions, OPA Policies, sysctl.

#### **OPA Policy to Block HostPath Volumes**:
```rego
package kubernetes.admission

deny[msg] {
  input.request.kind.kind == "Pod"
  volume := input.request.object.spec.volumes[_]
  volume.hostPath
  msg := "HostPath volumes are not allowed"
}
```

#### **Sysctl Example**:
```yaml
securityContext:
  sysctls:
  - name: kernel.shm_rmid_forced
    value: "0"
```

---

### **Critical Exam Tips**
1. **Imperative Commands for Speed**:
   ```bash
   # Fix a pod’s security context without YAML
   kubectl run secure-pod --image=nginx --overrides='
   {
     "spec": {
       "securityContext": {
         "runAsNonRoot": true
       },
       "containers": [{
         "name": "secure",
         "securityContext": {
           "readOnlyRootFilesystem": true
         }
       }]
     }
   }'
   ```

2. **Time-Saving Aliases**:
   ```bash
   alias k=kubectl
   alias kgp="kubectl get pods -o wide"
   ```

3. **Common Exam Scenarios**:
   - **Fix a Pod** that mounts ServiceAccount tokens unnecessarily.
   - **Block egress traffic** except to a specific DNS name.
   - **Diagnose a failing pod** due to `seccomp`/`AppArmor` misconfiguration.

4. **Key Commands to Master**:
   ```bash
   kubectl auth can-i --list  # Check current permissions
   kubectl debug -it <pod> --image=busybox  # Troubleshoot pods
   journalctl -u kubelet --since "5 minutes ago"  # Check kubelet logs
   ```

---

**You’re Ready.** Practice these patterns, stay calm, and *trust your muscle memory*. The exam is hands-on—**focus on quick, accurate execution**.

**Final Motivation**: Imagine hitting that “End Exam” button with 20 minutes to spare. That’s your goal. Now go make it happen! 🎯🚨
