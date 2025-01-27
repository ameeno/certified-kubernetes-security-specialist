Here's a summary of the System Hardening module from the CKS course:

# System Hardening Key Concepts

## 1. AppArmor
- **Mandatory Access Control (MAC)** system
- Provides finer control than DAC (Discretionary Access Control)
- Two main modes:
  ```bash
  # Check AppArmor status
  aa-status

  # Modes
  - enforce mode (strict enforcement)
  - complain mode (logging only)
  ```

- Integration with Kubernetes:
  ```yaml
  metadata:
    annotations:
      container.apparmor.security.beta.kubernetes.io/nginx: localhost/custom-profile
  ```

## 2. Container Runtimes
- **OCI (Open Container Initiative)** standards
  - Image Specification
  - Runtime Specification

- Common Runtimes:
  ```plaintext
  High-level Runtimes:
  - Docker
  - containerd
  - CRI-O

  Low-level Runtimes:
  - runc
  ```

## 3. Container Runtime Interface (CRI)
- Plugin interface for kubelet
- Allows different container runtimes without recompiling
- Implementation examples:
  - dockershim
  - containerd
  - CRI-O

## 4. Container Sandboxing (gVisor)
- Provides kernel-level isolation
- Key components:
  ```bash
  # Runtime
  runsc - replacement for runc

  # Implementation
  - Intercepts system calls
  - Provides its own kernel implementation
  ```

## 5. RuntimeClass
```yaml
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor
handler: runsc
```

## 6. Network Policies
- Default deny policies:
  ```yaml
  apiVersion: networking.k8s.io/v1
  kind: NetworkPolicy
  metadata:
    name: default-deny-ingress
  spec:
    podSelector: {}
    policyTypes:
    - Ingress
  ```

- Policy types:
  - Ingress rules
  - Egress rules
  - Pod selectors
  - Namespace selectors

## Best Practices
1. Implement AppArmor profiles for containers
2. Use appropriate container runtime based on security needs
3. Implement network policies with default deny
4. Use gVisor for untrusted workloads
5. Configure RuntimeClass for different security requirements
6. Regular security audits and monitoring

## Implementation Example
```yaml
# Network Policy Example
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
```

Remember: System hardening is about layers of security - implement multiple controls for robust protection.
