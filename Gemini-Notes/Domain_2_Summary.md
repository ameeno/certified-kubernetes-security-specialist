
# Domain 2: Cluster Hardening Summary

## Core Concepts

*   **RBAC (Role-Based Access Control):**
    *   **Roles & ClusterRoles:** `Roles` are namespaced resources that grant permissions to resources within that namespace. `ClusterRoles` are non-namespaced and can grant permissions to cluster-scoped resources or to all namespaces.
    *   **RoleBindings & ClusterRoleBindings:** `RoleBindings` grant the permissions defined in a `Role` to a user or set of users within a specific namespace. `ClusterRoleBindings` grant the permissions in a `ClusterRole` across the entire cluster.
*   **Service Accounts:**
    *   Service accounts provide an identity for processes that run in a Pod.
    *   By default, a service account token is automatically mounted into each pod, which can be a security risk if not managed.
    *   It is a best practice to disable automounting of service account tokens where they are not needed (`automountServiceAccountToken: false`).
*   **Projected Volumes:**
    *   Projected volumes allow you to mount several existing volume sources into the same directory.
    *   This is useful for securely mounting service account tokens with a specified audience and expiration, reducing the risk of token theft.
*   **Cluster Upgrades:**
    *   The `kubeadm` tool provides a structured workflow for upgrading Kubernetes clusters (`kubeadm upgrade plan` and `kubeadm upgrade apply`).
    *   Upgrading control plane and worker nodes involves updating `kubeadm`, `kubelet`, and `kubectl` packages and following a specific sequence of commands to ensure a smooth rollout.

## Essential Commands

*   **`kubectl` (RBAC):**
    ```bash
    # Create a Role
    kubectl create role <role-name> --verb=<verb> --resource=<resource> --namespace=<namespace>

    # Create a RoleBinding
    kubectl create rolebinding <binding-name> --role=<role-name> --user=<user-name> --namespace=<namespace>

    # Create a ClusterRole
    kubectl create clusterrole <clusterrole-name> --verb=<verb> --resource=<resource>

    # Create a ClusterRoleBinding
    kubectl create clusterrolebinding <binding-name> --clusterrole=<clusterrole-name> --user=<user-name>

    # Check permissions
    kubectl auth can-i <verb> <resource> --as <user-name>
    ```

*   **`kubectl` (Service Accounts):**
    ```bash
    # Get service accounts
    kubectl get serviceaccount --all-namespaces

    # Edit a service account to disable automount
    kubectl edit sa <sa-name> -n <namespace>
    # (Set automountServiceAccountToken: false)
    ```

*   **`kubeadm` (Upgrades):**
    ```bash
    # Check for available upgrades
    kubeadm upgrade plan

    # Apply the upgrade
    kubeadm upgrade apply <version>

    # Upgrade a worker node
    kubeadm upgrade node
    ```

*   **`apt-get` / `yum` (Package Management for Upgrades):**
    ```bash
    # Unhold packages to allow upgrades
    apt-mark unhold kubeadm kubelet kubectl

    # Install a specific version
    apt-get install -y kubeadm=<version> kubelet=<version> kubectl=<version>

    # Hold packages to prevent accidental upgrades
    apt-mark hold kubeadm kubelet kubectl
    ```

*   **`kubectl` (Node Management for Upgrades):**
    ```bash
    # Drain a node before maintenance
    kubectl drain <node-name> --ignore-daemonsets

    # Uncordon a node after maintenance
    kubectl uncordon <node-name>
    ```
