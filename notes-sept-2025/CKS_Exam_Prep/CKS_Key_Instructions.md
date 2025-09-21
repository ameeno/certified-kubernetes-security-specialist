
# CKS Key Instructions

## Cluster Setup & Hardening

### kubeadm
- **Cluster Creation:** `kubeadm init [flags]`
- **Joining Nodes:** `kubeadm join <control-plane-host>:<port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>`
- **Configuration:** `/etc/kubernetes/kubeadm-config.yaml`
- **Certificates:** Located in `/etc/kubernetes/pki/`.
- **Manifests:** Static pod manifests are in `/etc/kubernetes/manifests/`.

### API Server
- **Flags:**
  - `--authorization-mode=Node,RBAC`
  - `--encryption-provider-config`
  - `--tls-cert-file`, `--tls-private-key-file`
  - `--client-ca-file`
  - `--audit-policy-file`, `--audit-log-path`
  - `--anonymous-auth=false`
- **Configuration File:** `/etc/kubernetes/manifests/kube-apiserver.yaml`

### Kubelet
- **Flags:**
  - `--anonymous-auth=false`
  - `--authorization-mode=Webhook`
  - `--authentication-token-webhook=true`
- **Configuration File:** `/var/lib/kubelet/config.yaml`

### etcd
- **Encryption:** Use `--encryption-provider-config` in kube-apiserver.
- **etcdctl:**
  - `etcdctl snapshot save <snapshot-file>`
  - `etcdctl snapshot restore <snapshot-file> --data-dir <new-data-dir>`
- **Secure communication:** Use `--cert-file`, `--key-file`, `--trusted-ca-file`, `--client-cert-auth`

## System Hardening

### CIS Benchmarks
- **Tool:** `kube-bench`
- **Run:** `kube-bench`

### Docker Daemon
- **Remove users from docker group:** `gpasswd -d <user> docker`
- **Secure socket:** `chown root:root /var/run/docker.sock`
- **Disable TCP:** Remove `tcp://0.0.0.0:2375` from `/lib/systemd/system/docker.service`

## Minimizing Microservice Vulnerabilities

### Network Policies
- **Default Deny:**
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
- **Allow Ingress:**
  ```yaml
  ...
  spec:
    podSelector:
      matchLabels:
        app: my-app
    ingress:
    - from:
      - podSelector:
          matchLabels:
            app: client-app
  ```

### Ingress with TLS
- **Create TLS Secret:** `kubectl create secret tls <secret-name> --cert=<cert-file> --key=<key-file>`
- **Ingress with TLS:**
  ```yaml
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: my-ingress
    annotations:
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
  spec:
    ingressClassName: nginx
    tls:
    - hosts:
      - myapp.com
      secretName: <secret-name>
    rules:
    - host: myapp.com
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: my-service
              port:
                number: 80
  ```

## Supply Chain Security

### Image Security
- **Trivy:** `trivy image <image-name>`
- **Dockerfile Best Practices:**
  - Use minimal base images (e.g., `alpine`).
  - Use multi-stage builds.
  - Run as a non-root user (`USER <user>`).
  - Reduce layers by combining `RUN` commands.
- **ImagePolicyWebhook:** Configure in kube-apiserver to validate images before deployment.

### SBOM
- **Tool:** `bom`
- **Generate SPDX report:** `bom generate -f <image> -o <file.spdx.json>`

## Monitoring, Logging, and Runtime Security

### Falco
- **Custom Rules:** Edit `/etc/falco/falco_rules.local.yaml`.
- **Example Rule:**
  ```yaml
  - rule: Detect Shell in Container
    desc: Detects when a shell is spawned in a container.
    condition: spawned_process and container and proc.name in (bash, sh, zsh)
    output: "Shell spawned in a container (user=%user.name container_id=%container.id container_name=%container.name shell=%proc.name parent=%proc.pname cmdline=%proc.cmdline)"
    priority: WARNING
  ```

### Auditing
- **Audit Policy File:** `/etc/kubernetes/audit-policy.yaml`
- **Example Policy:**
  ```yaml
  apiVersion: audit.k8s.io/v1
  kind: Policy
  rules:
  - level: RequestResponse
    resources:
    - group: ""
      resources: ["pods"]
  ```
- **kube-apiserver flags:** `--audit-policy-file`, `--audit-log-path`, `--audit-log-maxage`, `--audit-log-maxbackup`, `--audit-log-maxsize`

### Seccomp
- **Profile:** Create a seccomp profile in a JSON file.
- **Apply to Pod:**
  ```yaml
  securityContext:
    seccompProfile:
      type: Localhost
      localhostProfile: profiles/my-profile.json
  ```
