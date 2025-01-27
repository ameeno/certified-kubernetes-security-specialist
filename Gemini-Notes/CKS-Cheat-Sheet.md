
# CKS Exam Cheat Sheet

## Imperative Commands (`kubectl`)

| Task | Command |
| --- | --- |
| **RBAC** | |
| Create Role | `kubectl create role <name> --verb=<verb> --resource=<resource> -n <ns>` |
| Create ClusterRole | `kubectl create clusterrole <name> --verb=<verb> --resource=<resource>` |
| Create RoleBinding | `kubectl create rolebinding <name> --role=<role> --user=<user> -n <ns>` |
| Create ClusterRoleBinding| `kubectl create clusterrolebinding <name> --clusterrole=<role> --user=<user>` |
| Check Permissions | `kubectl auth can-i <verb> <resource> --as <user> -n <ns>` |
| **Network** | |
| Create Ingress | `kubectl create ingress <name> --class=nginx --rule="host/path=svc:port"` |
| Create Network Policy | `kubectl create netpol <name> --pod-selector=<labels> --policy-types=<types>` |
| **Secrets** | |
| Create Generic Secret | `kubectl create secret generic <name> --from-literal=key=value` |
| Create TLS Secret | `kubectl create secret tls <name> --key <key> --cert <cert>` |
| **Scheduling** | |
| Taint a Node | `kubectl taint node <node> key=value:Effect` |
| Remove Taint | `kubectl taint node <node> key:Effect-` |
| **Cluster Admin** | |
| Drain a Node | `kubectl drain <node> --ignore-daemonsets` |
| Uncordon a Node | `kubectl uncordon <node>` |
| **Pod Security** | |
| Label ns for PSS | `kubectl label ns <ns> pod-security.kubernetes.io/enforce=restricted` |

---

## Key File Locations & API Server Flags

| Component | Path / Flag | Notes |
| --- | --- | --- |
| **API Server** | `/etc/kubernetes/manifests/kube-apiserver.yaml` | Static pod manifest. |
| | `--tls-cert-file`, `--tls-private-key-file` | API server TLS certs. |
| | `--client-ca-file` | CA for authenticating clients. |
| | `--authorization-mode=RBAC` | Must include RBAC. |
| | `--audit-policy-file=<file>` | Path to audit policy. |
| | `--audit-log-path=<path>` | Where to write audit logs. |
| | `--encryption-provider-config=<file>`| Enables encryption at rest. |
| | `--enable-admission-plugins` | e.g., `NodeRestriction`, `PodSecurity` |
| **Kubelet** | `/var/lib/kubelet/config.yaml` | Kubelet configuration. |
| | `/etc/systemd/system/kubelet.service.d/10-kubeadm.conf` | Kubeadm-managed settings. |
| **etcd** | `/etc/kubernetes/manifests/etcd.yaml` | Static pod manifest for etcd. |
| | `--cert-file`, `--key-file`, `--trusted-ca-file` | etcd TLS configuration. |
| **Audit Policy** | `/etc/kubernetes/audit-policy.yaml` | User-defined location. |
| **CNI Config** | `/etc/cni/net.d/` | CNI configuration files. |

---

## Security Tool Syntax

| Tool | Command | Example Use Case |
| --- | --- | --- |
| **Trivy** | `trivy image <image>` | Scan an image for CVEs. |
| | `trivy image --format spdx-json -o sbom.json <image>` | Generate an SBOM. |
| | `trivy sbom sbom.json` | Scan an SBOM for CVEs. |
| **Falco** | `journalctl -u falco -f` | View Falco alerts. |
| | `/etc/falco/falco_rules.local.yaml` | Add custom rules here. |
| | `systemctl restart falco` | Reload rules. |
| **AppArmor**| `apparmor_parser -q <profile>` | Load a profile. |
| | `aa-status` | View loaded profiles. |
| | `kubectl annotate pod <pod> container.apparmor.security.beta.kubernetes.io/<container>=localhost/<profile>` | Apply profile to pod (old way). |
| **kube-bench**| `kube-bench` | Run CIS benchmark checks. |
| **checkov** | `checkov -f <manifest.yaml>` | Static analysis of manifests. |

---

## Pod Security Context & PSS

**Pod Security Standards (PSS) Labels for Namespaces:**

*   `pod-security.kubernetes.io/enforce`: `privileged` / `baseline` / `restricted`
*   `pod-security.kubernetes.io/warn`: `privileged` / `baseline` / `restricted`
*   `pod-security.kubernetes.io/audit`: `privileged` / `baseline` / `restricted`

**Restricted Pod `securityContext` (Example):**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: restricted-pod
spec:
  containers:
  - name: my-container
    image: busybox
    securityContext:
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      runAsUser: 1001
      capabilities:
        drop: ["ALL"]
      seccompProfile:
        type: RuntimeDefault
```

---

## JSONPath & Audit Policy Snippets

**Common JSONPath Queries:**

| Description | Query |
| --- | --- |
| Get pod names | `kubectl get pods -o jsonpath='{.items[*].metadata.name}'` |
| Get node internal IPs | `kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'` |
| Get container images | `kubectl get pods -o jsonpath='{.items[*].spec.containers[*].image}'` |
| Find container ID | `kubectl get pods -A -o jsonpath='{.items[?(@.metadata.name=="<pod-name>")].status.containerStatuses[0].containerID}'` |

**Minimal Audit Policy:**

```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  # Log secret changes at the RequestResponse level
  - level: RequestResponse
    resources:
    - group: ""
      resources: ["secrets"]

  # Log pod changes at the Metadata level
  - level: Metadata
    resources:
    - group: ""
      resources: ["pods"]

  # Ignore everything else
  - level: None
```
