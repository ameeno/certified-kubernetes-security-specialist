
# Domain 3: Minimize Microservice Vulnerabilities Summary

## Core Concepts

*   **Security Contexts:** Applying security settings to Pods and Containers. This includes:
    *   `runAsUser` / `runAsGroup`: Running processes as a specific user/group ID.
    *   `readOnlyRootFilesystem`: Preventing writes to a container's root filesystem.
    *   `allowPrivilegeEscalation`: Controlling whether a process can gain more privileges than its parent.
    *   `privileged`: Running a container with full access to the host machine (highly discouraged).
*   **Linux Capabilities:** Granting specific kernel-level permissions to a container rather than giving it full root access. This follows the principle of least privilege.
*   **Pod Security Standards (PSS):** Cluster-wide policies that define different levels of security for pods (`privileged`, `baseline`, `restricted`). These are enforced at the namespace level via labels.
*   **Admission Controllers:** Intercepting requests to the Kubernetes API server to validate or mutate them. Key security-related admission controllers include:
    *   `ImagePolicyWebhook`: Using an external webhook to validate images before they are allowed to run.
    *   `AlwaysPullImages`: Forcing Kubernetes to pull the image on every pod startup, ensuring the latest version is used and preventing the use of stale or tampered local images.
*   **Secrets Management:** Understanding how to create, manage, and securely mount secrets into pods, either as files or environment variables.
*   **Cilium:** A CNI (Container Network Interface) that provides advanced networking and security capabilities.
    *   **Cilium Network Policies (CNP):** An extension of Kubernetes Network Policies with more advanced features like Layer 7 (e.g., HTTP) and DNS-based policies.
    *   **Transparent Encryption:** Securing pod-to-pod communication across nodes using technologies like IPsec or WireGuard.

## Essential Commands

*   **`kubectl` (Security Contexts & PSS):**
    ```bash
    # Run a privileged pod (for demonstration)
    kubectl run privileged-pod --image=busybox --privileged -- sleep 36000

    # Apply a Pod Security Standard to a namespace
    kubectl label namespace <ns-name> pod-security.kubernetes.io/enforce=restricted
    ```

*   **Pod Manifest (Security Context):**
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: secure-pod
    spec:
      containers:
      - name: my-container
        image: busybox
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1001
          readOnlyRootFilesystem: true
          capabilities:
            drop: ["ALL"]
          seccompProfile:
            type: RuntimeDefault
    ```

*   **`kubectl` (Secrets):**
    ```bash
    # Create a secret from a literal value
    kubectl create secret generic <secret-name> --from-literal=key=value

    # Create a secret from a file
    kubectl create secret generic <secret-name> --from-file=./path/to/file
    ```

*   **`cilium` CLI & `kubectl` (Cilium):**
    ```bash
    # Install Cilium
    cilium install

    # Check Cilium status
    cilium status

    # Create a Cilium Network Policy
    kubectl create -f <cnp-policy.yaml>

    # List Cilium Network Policies
    kubectl get cnp
    ```

*   **Cilium Network Policy (CNP) Example:**
    ```yaml
    apiVersion: "cilium.io/v2"
    kind: CiliumNetworkPolicy
    metadata:
      name: "allow-dns-to-google"
    spec:
      endpointSelector: {}
      egress:
      - toPorts:
        - ports:
          - port: "53"
          rules:
            dns:
             - matchPattern: "*.google.com"
    ```

*   **`setcap` / `getcap` (Linux Capabilities on Host):**
    ```bash
    # Grant a capability to a binary
    setcap 'cap_net_bind_service=+ep' /path/to/binary

    # View capabilities of a binary
    getcap /path/to/binary
    ```
