# CKS Exam Cram Sheet

## 1. Cluster Setup & Hardening

### CIS Benchmarks
- Use `kube-bench` for security compliance checking
- Focus on master and worker node configurations
- Implement both CIS + custom hardening guidelines

### ETCD Security
- Enable encryption at rest for ETCD
- Configure TLS for in-transit encryption
- Implement client certificate authentication
- Key flags:
  ```bash
  --client-cert-auth
  --trusted-ca-file
  ```

### API Server Security
- Configure TLS/HTTPS
- Disable insecure port (set `--insecure-port=0`)
- Enable encryption for secrets storage
- Implement proper authentication methods

### Authentication Methods
1. X.509 Certificates
   - Most secure for production
   - Requires certificate management
   - Groups mapped via Organization (O) field

2. OIDC (OpenID Connect)
   - Integration with identity providers
   - Uses tokens (access_token, id_token)
   - Better for user management

3. Service Accounts
   - For pod-to-API server communication
   - Namespace scoped
   - Automatically mounted to pods

### RBAC (Role-Based Access Control)
- Role vs ClusterRole
- RoleBinding vs ClusterRoleBinding
- Key commands:
  ```bash
  kubectl create role
  kubectl create rolebinding
  kubectl auth can-i
  ```

## 2. System Hardening

### AppArmor
- Create profiles for containers
- Apply profiles via pod annotations
- Verify profile loading on nodes

### Network Policies
- Define ingress/egress rules
- Use pod/namespace selectors
- Default deny all traffic first

### Pod Security
- Avoid privileged pods
- Implement Pod Security Policies
- Use securityContext configurations
- Control capabilities

## 3. Supply Chain Security

### Image Security
- Implement ImagePolicyWebhook
- Use Trivy for image scanning
- Follow Dockerfile best practices:
  - Non-root users
  - Minimal base images
  - Multi-stage builds

### Runtime Security
- Deploy Falco for runtime monitoring
- Create custom Falco rules
- Monitor suspicious activities

## 4. Monitoring & Logging

### Audit Logging
- Configure audit policy
- Define audit log backend
- Key areas to monitor:
  - Authentication attempts
  - Resource access
  - Configuration changes

## Exam Tips

1. Time Management
- Complete easier tasks first
- Leave complex monitoring tasks for last
- Verify your work quickly

2. Common Tasks
- Create roles and bindings
- Configure network policies
- Set up TLS certificates
- Implement security contexts
- Scan containers for vulnerabilities

3. Must-Know Commands
```bash
# RBAC
kubectl create role/clusterrole
kubectl create rolebinding/clusterrolebinding

# Security Context
kubectl create pod --security-context

# Network Policies
kubectl create networkpolicy

# Certificate Management
openssl req -new -key user.key -subj "/CN=user/O=group" -out user.csr
```

4. Key Files/Locations
- API server config: `/etc/kubernetes/manifests/kube-apiserver.yaml`
- ETCD config: `/etc/kubernetes/manifests/etcd.yaml`
- Certificates: `/etc/kubernetes/pki/`
- Audit logs: `/var/log/audit/`

Remember to:
- Always verify configurations
- Use `kubectl explain` for resource details
- Check logs for troubleshooting
- Validate security configurations before moving to next task

This cram sheet covers the major exam topics. Focus on hands-on practice with these concepts, especially RBAC, Network Policies, and Security Contexts.
