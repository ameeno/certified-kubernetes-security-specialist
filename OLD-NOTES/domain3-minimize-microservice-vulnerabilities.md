## admission controllers.
addmissions controllers happen at the third stage, after authenticating (credentials) authorising (roles/permissions), the final step is admission controllers.
2 types: Validating && mutating
Validating = set of rules that pods / services must conform to to be launched. and function, example, if the validating controller states that pods must have a label, then if a pod is launched without a label, it will be rejected.

Mutating=  set of rules that pods / services can be modified before being launched. and function, example, if the mutating controller states that pods must have a label, then if a pod is launched without a label, it will be modified and added a label.

thus a mutating ensures a particular set of rules are followed, even if not explicitly stated, or provided in spec.
but validating restricts launching of services/pods not in spec.


multiple addmission controllers available:
AlwaysPullImages
PodNodeSelector
PodSecurityPolicy
LimitRanger
NamespaceExists
EventRateLimit

need to read up on them.
some addmissions controlers are deprecated, so keep not of that.

## Security Context
By default pods run as root user inside pod and have inside container root privileges. this is dangerous as if there is ever a vulnerability in the container, it can be exploited by the root user. and he may be able to breakout of the pod into the host system and do damage to the os or other pods.

for this we need to set the security context.
example security context in a pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000 # fsgroup for volume mounted files.
  containers:
  - name: sec-ctx-demo
    image: nginx
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL

```
## Privileged pods and containers
privileged containers have access to hardware of the root system in a similar fashion to running as root on the host, they have access to the full dev tree and other things.

k8's allows for privileged pods and containers.
you can allow containers privileged as true in spec


Here's a summary of key points from the Minimize Microservice Vulnerabilities module:

# CKS Microservice Security Summary

## 1. Admission Controllers
- Acts as gatekeepers that intercept API requests
- Runs after authentication but before persistence
- Two types:
  1. Validating Admission Controllers
  2. Mutating Admission Controllers

### Key Controllers:
```yaml
# Common Admission Controllers
- AlwaysPullImages
- PodNodeSelector
- PodSecurityPolicy
- LimitRanger
- NamespaceExists
- EventRateLimit
```

## 2. Security Context
- Default containers run as root (UID 0)
- Best Practices:
```yaml
securityContext:
  runAsUser: 1000
  runAsGroup: 3000
  fsGroup: 2000
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
```

## 3. Privileged Containers
- By default, containers have limited capabilities
- Privileged containers can:
  - Access host devices
  - Run with elevated permissions
  - Bypass security controls
- Security Risk: Container breakout potential

## 4. Pod Security Policies (PSP)
- Controls security-sensitive aspects of pod specification
- Key controls:
```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - configMap
    - emptyDir
    - persistentVolumeClaim
    - secret
  runAsUser:
    rule: MustRunAsNonRoot
```

## 5. Volume Security
- HostPath volumes pose security risks
- Recommended volume types:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - secret
  - projected

## 6. Image Pull Policies
Three options:
```yaml
imagePullPolicy:
  - Always      # Always pull image
  - IfNotPresent # Use local if exists
  - Never       # Only use local image
```

## 7. AlwaysPullImages Admission Controller
- Forces `imagePullPolicy: Always`
- Ensures fresh image pulls
- Prevents unauthorized image use

## 8. ImagePolicyWebhook
Implementation steps:
1. Create configuration file
2. Create kubeconfig file
3. Mount volumes to API server
4. Enable admission controller

## 9. Kubernetes Secrets
- Stores sensitive data centrally
- Types:
  - Generic
  - Docker registry
  - TLS
- Mounting options:
  - As volumes
  - As environment variables

## Security Best Practices
1. Use non-root users
2. Implement PSPs
3. Limit container capabilities
4. Use read-only root filesystem
5. Implement network policies
6. Regular security scanning
7. Proper secret management
8. Enable admission controllers

## Implementation Example
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
    image: nginx:1.19
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
    volumeMounts:
    - name: secrets
      mountPath: "/etc/secrets"
      readOnly: true
  volumes:
  - name: secrets
    secret:
      secretName: app-secrets
```

Remember: Security is layered - implement multiple controls for robust protection.
