# 🚀 **CKS Exam Cram Sheet**

---

## 🔑 RBAC

```bash
# Role
kubectl create role pod-reader --verb=get,list,watch --resource=pods -n dev \
  --dry-run=client -o yaml > role.yaml

# RoleBinding
kubectl create rolebinding read-pods \
  --role=pod-reader --user=alice -n dev \
  --dry-run=client -o yaml > rb.yaml

# ClusterRole
kubectl create clusterrole secret-admin --verb=get,list,watch --resource=secrets \
  --dry-run=client -o yaml > cr.yaml

# ClusterRoleBinding
kubectl create clusterrolebinding secret-admin-binding \
  --clusterrole=secret-admin --serviceaccount=dev:sa1 \
  --dry-run=client -o yaml > crb.yaml
```

---

## 👤 Service Accounts

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sa1
  namespace: dev
```

Assign to Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
  namespace: dev
spec:
  serviceAccountName: sa1
  containers:
  - name: nginx
    image: nginx
```

Disable auto-mount:

```yaml
automountServiceAccountToken: false
```

---

## 🛡️ Pod Security Context

```yaml
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
      runAsNonRoot: true
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
        add: ["NET_BIND_SERVICE"]
```

Privileged pod (avoid unless asked):

```yaml
securityContext:
  privileged: true
```

---

## 🔒 Network Policies

Default deny:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: dev
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

Allow app → db:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: app-db
  namespace: dev
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: app
```

Allow egress to IP:

```yaml
egress:
- to:
  - ipBlock:
      cidr: 8.8.8.8/32
```

---

## 🔑 Secrets

```bash
kubectl create secret generic db-secret \
  --from-literal=username=admin --from-literal=password=pass123 \
  -n dev
```

Mount as env:

```yaml
env:
- name: DB_USER
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: username
```

Mount as volume:

```yaml
volumes:
- name: secret-vol
  secret:
    secretName: db-secret
containers:
- volumeMounts:
  - name: secret-vol
    mountPath: "/etc/secret"
```

---

## 🌐 Ingress with TLS

```bash
kubectl create secret tls tls-secret \
  --cert=cert.crt --key=cert.key -n dev
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - example.com
    secretName: tls-secret
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-svc
            port:
              number: 80
```

---

## 📜 Audit Policy

```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
```

API server flags:

```
--audit-policy-file=/etc/kubernetes/audit-policy.yaml
--audit-log-path=/var/log/apiserver/audit.log
```

---

## 🗝️ Encryption at Rest (Secrets in etcd)

`encryption-config.yaml`

```yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
- resources: ["secrets"]
  providers:
  - aescbc:
      keys:
      - name: key1
        secret: <BASE64-ENCODED-KEY>
  - identity: {}
```

API server flag:

```
--encryption-provider-config=/etc/kubernetes/encryption-config.yaml
```

---

## 🔍 Quick kubectl helpers

```bash
kubectl run tmp --rm -it --image=busybox -- /bin/sh   # quick pod
kubectl auth can-i get pods --as=system:serviceaccount:dev:sa1 -n dev
kubectl get pods -o wide
kubectl describe pod <pod>
kubectl logs <pod>
kubectl exec -it <pod> -- sh
```

---

## ⚡ etcd / etcdctl

```bash
# Secure etcdctl connection
etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key get / --prefix --keys-only

# Snapshot
etcdctl snapshot save /var/lib/etcd/snapshot.db
# Restore
etcdctl snapshot restore /var/lib/etcd/snapshot.db --data-dir=/var/lib/etcd
```

---

## 📡 kube-apiserver Flags

```bash
--encryption-provider-config=/etc/kubernetes/encryption-config.yaml
--audit-policy-file=/etc/kubernetes/audit-policy.yaml
--audit-log-path=/var/log/apiserver/audit.log
--authorization-mode=Node,RBAC
--token-auth-file=/etc/kubernetes/token.csv
--tls-cert-file=/etc/kubernetes/pki/apiserver.crt
--tls-private-key-file=/etc/kubernetes/pki/apiserver.key
--client-ca-file=/etc/kubernetes/pki/ca.crt
```

---

## 🖥️ kubelet Flags

```bash
--anonymous-auth=false
--tls-cert-file=/var/lib/kubelet/pki/kubelet.crt
--tls-private-key-file=/var/lib/kubelet/pki/kubelet.key
--client-ca-file=/etc/kubernetes/pki/ca.crt
--authorization-mode=Webhook
--authentication-token-webhook=true
```

---

## 🔐 kube-controller-manager

```bash
--use-service-account-credentials=true
--root-ca-file=/etc/kubernetes/pki/ca.crt
--service-account-private-key-file=/etc/kubernetes/pki/sa.key
```

---

## 📋 kube-scheduler

```bash
--authentication-kubeconfig=/etc/kubernetes/scheduler.conf
--authorization-kubeconfig=/etc/kubernetes/scheduler.conf
```

---

## 🔏 Systemd Handy

```bash
systemctl status kubelet -l
journalctl -u kubelet -f
systemctl restart etcd kubelet kube-apiserver
```

---

## 🔒 Pod Security Admission

```bash
kubectl label ns dev pod-security.kubernetes.io/enforce=restricted
kubectl label ns dev pod-security.kubernetes.io/enforce-version=v1.27
```

---

## 📦 Admission Plugins

```bash
--enable-admission-plugins=AlwaysPullImages,PodSecurity,NodeRestriction
```

---

## 🧾 Common File Paths (kubeadm-based)

```
/etc/kubernetes/pki/ca.crt
/etc/kubernetes/pki/apiserver.crt
/etc/kubernetes/pki/apiserver.key
/etc/kubernetes/pki/etcd/ca.crt
/etc/kubernetes/pki/etcd/server.crt
/etc/kubernetes/pki/etcd/server.key
/etc/kubernetes/encryption-config.yaml
/etc/kubernetes/audit-policy.yaml
/etc/kubernetes/admin.conf
```
