# Kubernetes Security Notes: Authentication & Authorization

## API Server Security Flow
There are three sequential steps between you and the API server:
1. Authentication
2. Authorization
3. Admission Controller

## 1. Authentication Methods

### Token Authentication
Uses CSV file containing tokens
#### Downsides:
- Tokens stored in plain text on API server
- Tokens cannot be revoked/rotated without API server restart
- Not recommended for production use

### X509 Certificate Authentication
Uses certificates signed by trusted CA
#### Downsides:
- Private keys typically stored on unencrypted media (security risk)
- Certificates are long-lived (K8s lacks certificate revocation)
- Groups (Organizations) in certificates cannot be modified without reissuing
  - Format: `/CN=Common_Name/O=Organization`
  - Old certificates remain valid!

### OpenID Connect Authentication
- Uses third-party Identity Provider (e.g., OKTA)
- API server must trust the identity provider
- Uses OIDC URL, client ID, and token
- Out of exam scope (too complex)

## 2. Authorization

### Available Modes
Set via `--authorization-mode` flag on API server (default: "AlwaysAllow")

| Mode | Description |
|------|-------------|
| AlwaysDeny | Blocks all requests (testing only) |
| AlwaysAllow | Allows all requests (no authorization) |
| RBAC | Role-Based Access Control (most common) |
| ABAC | Attribute-Based Access Control |
| Webhook | Custom authorization logic |
| Node | Special mode for kubelet permissions |

### RBAC Details
- Most commonly used authorization mode
- `system:masters` group has full admin access
- Deleting all roles doesn't affect `system:masters` access

#### Example: Creating Certificate for system:masters
```bash
cd /root/certificates
openssl genrsa -out bob.key 2048
openssl req -new -key bob.key -subj "/CN=bob/O=system:masters" -out bob.csr
openssl x509 -req -in bob.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out bob.crt -extensions v3_req -days 1000
```

Using the certificate:
```bash
kubectl get secret --server=https://127.0.0.1:6443 \
  --client-certificate /root/certificates/bob.crt \
  --certificate-authority /root/certificates/ca.crt \
  --client-key /root/certificates/bob.key
```

⚠️ **WARNING**: Combining certificate auth with `system:masters` is dangerous due to:
- Certificate revocation difficulties
- Long certificate lifetimes
- Unrestricted cluster access

## 3. Data Encryption

### ETCD Data Security
By default, ETCD stores data in plain text. Even with TLS:
- Data at rest remains unencrypted
- Secrets can be read directly from ETCD

#### Testing Unencrypted Data
Create a test secret:
```bash
kubectl create secret generic new-secret -n default \
  --from-literal=user=secretpassword \
  --server=https://127.0.0.1:6443 \
  --client-certificate /root/certificates/bob.crt \
  --certificate-authority /root/certificates/ca.crt \
  --client-key /root/certificates/bob.key
```

Verify unencrypted storage:
```bash
# View in ETCD
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --insecure-skip-tls-verify --insecure-transport=false \
  --cert ./apiserver.crt --key ./apiserver.key \
  get /registry/secrets/default/new-secret | hexdump -C

# Direct file search
cd /var/lib/etcd
grep -R "secretpassword" .
```

### Implementing Encryption
Use `EncryptionConfig` to encrypt ETCD data:

```bash
# Generate encryption key
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

# Create encryption config
cat > encryption-at-rest.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
```

Apply configuration:
```bash
mkdir /var/lib/kubernetes
mv encryption-at-rest.yaml /var/lib/kubernetes
# Add to API server: --encryption-provider-config=/var/lib/kubernetes/encryption-at-rest.yaml
systemctl daemon-reload
systemctl restart kube-apiserver
```

### Encryption Providers

| Provider | Type | Strength | Speed | Notes |
|----------|------|----------|-------|-------|
| Identity | None | None | N/A | Default |
| aescbc | AES-CBC with PKCS#7 | Strongest | Fast | Recommended |
| secretbox | XSalsa20-Poly1305 | Strong | Faster | Alternative |
| kms | Key Management Service | Strongest | Fast | External key management |

Note: Existing secrets remain unencrypted when enabling encryption.

## 4. Audit Logging
Provides chronological security records of cluster activities.

### Audit Information Captured
- What happened?
- When did it happen?
- Who initiated it?
- What was affected?
- Source location
- Destination

### Audit Policy Levels

| Level | Description |
|-------|-------------|
| None | No logging |
| Metadata | Log user, timestamp (no body) |
| Request | Log metadata + request body |
| RequestResponse | Log metadata + request + response |
