
# Domain 4: System Hardening Summary

## Core Concepts

*   **AppArmor:** A Linux security module that confines programs to a limited set of resources. AppArmor profiles can be loaded into the kernel and then applied to pods to restrict their capabilities, such as denying file writes.
*   **RuntimeClass:** A Kubernetes feature for selecting the container runtime configuration to use for running a pod's containers. This allows for using different runtimes for different pods, such as `gVisor` for sandboxed containers or `runc` for standard containers.
*   **gVisor:** A container sandbox that provides an additional layer of isolation between the container and the host kernel. It intercepts application system calls and acts as a guest kernel, reducing the attack surface.
*   **Container Runtimes (CRI & OCI):**
    *   **CRI (Container Runtime Interface):** A plugin interface that enables the kubelet to use different container runtimes.
    *   **OCI (Open Container Initiative):** A set of standards for container formats and runtimes. `runc` is a low-level OCI-compliant container runtime.
    *   Understanding the relationship between `kubelet`, `containerd` (a high-level CRI runtime), and `runc` (a low-level OCI runtime) is crucial.
*   **Network Policies:** While also covered in other domains, system hardening includes ensuring that a default-deny network policy is in place to restrict all traffic unless explicitly allowed.

## Essential Commands

*   **`apparmor_parser` & `aa-status`:**
    ```bash
    # Load an AppArmor profile
    apparmor_parser -q < /path/to/profile

    # Check the status of AppArmor profiles
    aa-status
    ```

*   **Pod Manifest (AppArmor):**
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: apparmor-pod
      annotations:
        container.apparmor.security.beta.kubernetes.io/<container-name>: localhost/<profile-name>
    spec:
      containers:
      - name: <container-name>
        image: busybox
        command: [ "sh", "-c", "echo 'Hello AppArmor!' && sleep 1h" ]
    ```
    *Note: The annotation method is older. The `securityContext.appArmorProfile` field is preferred in newer Kubernetes versions.*

*   **Pod Manifest (AppArmor - Modern Approach):**
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: hello-apparmor
    spec:
      securityContext:
        appArmorProfile:
          type: Localhost
          localhostProfile: <profile-name>
      containers:
      - name: hello
        image: busybox
        command: [ "sh", "-c", "echo 'Hello AppArmor!' && sleep 1h" ]
    ```

*   **`kubectl` (RuntimeClass):**
    ```bash
    # Get available RuntimeClasses
    kubectl get runtimeclass
    ```

*   **RuntimeClass & Pod Manifest (gVisor):**
    ```yaml
    # RuntimeClass definition
    apiVersion: node.k8s.io/v1
    kind: RuntimeClass
    metadata:
      name: gvisor-class
    handler: runsc # The handler name for gVisor

    # Pod using the RuntimeClass
    apiVersion: v1
    kind: Pod
    metadata:
      name: gvisor-pod
    spec:
      runtimeClassName: gvisor-class
      containers:
      - image: nginx
        name: nginx
    ```

*   **`ctr` & `runc` (Low-level container management):**
    ```bash
    # Pull an image with containerd
    ctr image pull docker.io/library/nginx:latest

    # Create a container with containerd
    ctr container create docker.io/library/nginx:latest my-nginx

    # Generate an OCI runtime spec
    runc spec

    # Run a container with runc
    runc run <container-id>
    ```
