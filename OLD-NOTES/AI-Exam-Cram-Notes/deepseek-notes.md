**CKS Exam Cram Cheatsheet - 3-Day Master Plan**
*You’ve got this! Focus on hands-on practice and key concepts. Let’s go!*

---

### **1. Cluster Hardening (20% Weight)**
**Key Topics**: RBAC, kubelet TLS, API Server AuthZ, Network Policies.

#### **Examples & Code**:
- **RBAC**:
  ```yaml
  # Create a Role to read pods
  apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    namespace: default
    name: pod-reader
  rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "watch", "list"]
  ---
  # Bind the Role to a ServiceAccount
  apiVersion: rbac.authorization.k8s.io/v1
  kind: RoleBinding
  metadata:
    name: read-pods
    namespace: default
  subjects:
  - kind: ServiceAccount
    name: default
    namespace: default
  roleRef:
    kind: Role
    name: pod-reader
    apiGroup: rbac.authorization.k8s.io
  ```
  - Verify: `kubectl auth can-i list pods --as=system:serviceaccount:default:default`

- **Network Policies**:
  ```yaml
  # Deny all ingress traffic by default
  apiVersion: networking.k8s.io/v1
  kind: NetworkPolicy
  metadata:
    name: deny-all-ingress
  spec:
    podSelector: {}
    policyTypes:
    - Ingress
  ```

---

### **2. System Hardening (15%)**
**Key Topics**: CIS Benchmarks, Minimize OS Footprint, Kernel Hardening (AppArmor/seccomp).

#### **Examples & Code**:
- **Check CIS Compliance**:
  ```bash
  # Run kube-bench (CIS benchmark tool)
  docker run --pid=host -v /etc:/etc:ro -v /var:/var:ro -t aquasec/kube-bench:latest master
  ```

- **seccomp Profile**:
  ```json
  # /var/lib/kubelet/seccomp/profiles/audit.json
  {
    "defaultAction": "SCMP_ACT_LOG"
  }
  ```
  ```yaml
  # Pod using the seccomp profile
  apiVersion: v1
  kind: Pod
  metadata:
    name: audit-pod
  spec:
    securityContext:
      seccompProfile:
        type: Localhost
        localhostProfile: profiles/audit.json
    containers:
    - name: test
      image: nginx
  ```

---

### **3. Minimize Microservice Vulnerabilities (20%)**
**Key Topics**: Security Contexts, PodSecurityPolicies (PSP)/PodSecurityAdmission, Image Scanning.

#### **Examples & Code**:
- **Pod SecurityContext**:
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: secure-pod
  spec:
    securityContext:
      runAsNonRoot: true
      runAsUser: 1000
    containers:
    - name: secure-container
      image: nginx
      securityContext:
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
  ```

- **Scan Images with Trivy**:
  ```bash
  trivy image nginx:latest
  ```

---

### **4. Supply Chain Security (20%)**
**Key Topics**: Image Signing (cosign), Admission Controllers, Trusted Registries.

#### **Examples & Code**:
- **Sign an Image with Cosign**:
  ```bash
  cosign generate-key-pair
  cosign sign --key cosign.key myregistry/myimage:v1
  ```

- **Verify Image in Admission Controller**:
  ```yaml
  # Use Connaisseur (example Admission Controller)
  apiVersion: admission.connaisseur.acl.dev/v1
  kind: AdmissionPolicy
  metadata:
    name: verify-image-signature
  spec:
    rules:
    - image: "myregistry/*"
      key: |
        -----BEGIN PUBLIC KEY-----
        ...
        -----END PUBLIC KEY-----
  ```

---

### **5. Monitoring & Logging (15%)**
**Key Topics**: Falco (Runtime Alerts), Audit Logs, Prometheus.

#### **Examples & Code**:
- **Falco Rule Example**:
  ```yaml
  # Alert on shell in container
  - rule: Terminal shell in container
    desc: A shell was run in a container
    condition: >
      spawned_process and container
      and shell_procs
    output: "Shell in container (user=%user.name %container.info)"
    priority: WARNING
  ```

- **Enable Audit Logs**:
  ```yaml
  # /etc/kubernetes/audit-policy.yaml
  apiVersion: audit.k8s.io/v1
  kind: Policy
  rules:
  - level: Metadata
    resources:
    - group: ""
      resources: ["secrets"]
  ```

---

### **6. Runtime Security (10%)**
**Key Topics**: Seccomp/AppArmor, ServiceAccount Restrictions, OPA/Gatekeeper.

#### **Examples & Code**:
- **Disable ServiceAccount Token Mount**:
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: no-token-mount
  spec:
    automountServiceAccountToken: false
    containers:
    - name: main
      image: nginx
  ```

---

### **Motivation & Tips**
- **Focus on Practice**: Use [killer.sh CKS Simulator](https://killer.sh) for timed drills.
- **Key Commands**:
  - `kubectl -n <ns> get <resource> -oyaml > file.yaml` → Modify & apply.
  - `kubectl explain pod.spec.securityContext` → Quick docs!
- **Exam Day**:
  - **Time Management**: Allocate ~10 mins/question. Skip & revisit if stuck.
  - **Imperative Commands**: Save time with `k run`, `k expose`, etc.

---

**Final Push**: You’re a Kubernetes warrior. Crush this exam! 🚀
