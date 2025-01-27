
# Domain 1: Cluster Setup Summary

## Core Concepts

*   **etcd Security:** Securing the etcd key-value store using TLS encryption for both server and client communication (mutual TLS).
*   **API Server Hardening:**
    *   Configuring the API Server to serve traffic over TLS.
    *   Enforcing client authentication using methods like x509 client certificates and static tokens.
    *   Implementing authorization modes, with a focus on Role-Based Access Control (RBAC).
    *   Enabling encryption at rest to protect sensitive data like Secrets within etcd.
*   **Audit Logging:** Configuring and enabling audit policies to log requests to the Kubernetes API server for security monitoring and analysis.
*   **Kubelet Security:** Hardening the kubelet by controlling authentication and authorization to its API, preventing anonymous access and unauthorized actions.
*   **Network Security:**
    *   **Ingress:** Managing external access to services within the cluster, often secured with TLS.
    *   **Network Policies:** Restricting traffic flow between pods at the network level to implement micro-segmentation.
*   **Cluster Installation:** Using `kubeadm` to bootstrap a secure Kubernetes cluster and understanding the location of critical configuration files and manifests.
*   **Binary Verification:** Ensuring the integrity of Kubernetes binaries by verifying their checksums.
*   **Scheduling:** Using Taints and Tolerations to control which nodes pods can be scheduled on.

## Essential Commands

*   **`openssl`**: Used for creating certificate authorities, signing certificates, and managing keys.
    ```bash
    # Generate a private key
    openssl genrsa -out <key-name>.key 2048

    # Create a Certificate Signing Request (CSR)
    openssl req -new -key <key-name>.key -subj "/CN=common-name/O=organization" -out <csr-name>.csr

    # Sign a CSR with a CA
    openssl x509 -req -in <csr-name>.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out <cert-name>.crt -days 365
    ```

*   **`kube-apiserver` (Flags)**: Critical flags for securing the API server.
    ```bash
    --tls-cert-file=<cert.crt>
    --tls-private-key-file=<key.key>
    --client-ca-file=<ca.crt>
    --authorization-mode=RBAC
    --audit-policy-file=<policy.yaml>
    --audit-log-path=<log-file>
    --encryption-provider-config=<config.yaml>
    --token-auth-file=<tokens.csv>
    ```

*   **`etcdctl`**: Command-line client for etcd.
    ```bash
    # Put a key-value pair (with TLS)
    etcdctl --endpoints=https://... --cacert=ca.crt --cert=client.crt --key=client.key put mykey "myvalue"

    # Get a key (with TLS)
    etcdctl --endpoints=https://... --cacert=ca.crt --cert=client.crt --key=client.key get mykey
    ```

*   **`kubeadm`**: Tool for bootstrapping Kubernetes clusters.
    ```bash
    # Initialize a cluster
    kubeadm init --pod-network-cidr=... --kubernetes-version=...

    # Join a worker node to the cluster
    kubeadm join <master-ip>:<port> --token <token> --discovery-token-ca-cert-hash <hash>
    ```

*   **`kubectl` (Security Context)**:
    ```bash
    # Create a TLS secret
    kubectl create secret tls <secret-name> --key <key-file> --cert <cert-file>

    # Create a Network Policy
    kubectl create -f <network-policy.yaml>

    # Taint a node
    kubectl taint node <node-name> key=value:NoSchedule
    ```

*   **`systemctl`**: Managing the lifecycle of systemd services like `kube-apiserver` and `etcd`.
    ```bash
    systemctl daemon-reload
    systemctl restart <service-name>
    systemctl status <service-name>
    ```
