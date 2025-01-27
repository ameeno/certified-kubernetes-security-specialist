
# CKS Hands-On Practice Guide

This guide provides practical, hands-on scenarios to build muscle memory for the CKS exam. For each scenario, focus on diagnosing the issue, implementing the fix, and verifying the result.

---

### Domain 1: Cluster Setup

1.  **Scenario: Secure etcd Communication**
    *   **Diagnose:** Use `tcpdump` to observe that traffic between the API server and etcd is unencrypted.
    *   **Remediate:**
        1.  Create a new Certificate Authority (CA) using `openssl`.
        2.  Generate a server certificate for etcd and a client certificate for the API server, both signed by your CA.
        3.  Configure the `etcd` process to use the server cert/key and require client certificate authentication (`--client-cert-auth`, `--trusted-ca-file`).
        4.  Configure the `kube-apiserver` to use the client cert/key to communicate with etcd (`--etcd-certfile`, `--etcd-keyfile`).
    *   **Verify:** Use `etcdctl` with the appropriate certs/keys to confirm you can still read/write to etcd. `tcpdump` should now show encrypted traffic (TLS).

2.  **Scenario: Isolate Pods with a Network Policy**
    *   **Diagnose:** Create two pods, `pod-a` and `pod-b`. Show that `pod-a` can successfully `curl` `pod-b`.
    *   **Remediate:**
        1.  Create a `NetworkPolicy` that selects `pod-b`.
        2.  Define an ingress rule that allows traffic *only* from pods with the label `app=frontend`.
        3.  Apply the label `app=frontend` to `pod-a`.
    *   **Verify:** Confirm that `pod-a` can still `curl` `pod-b`. Create a third pod, `pod-c` (without the label), and show that it *cannot* `curl` `pod-b`.

3.  **Scenario: Configure Audit Logging for Secrets**
    *   **Diagnose:** Create, update, or delete a Secret in the `default` namespace. Show that no audit log is generated.
    *   **Remediate:**
        1.  Create an audit policy file that logs all `secrets` resource requests at the `RequestResponse` level.
        2.  Configure the `kube-apiserver` to use this policy (`--audit-policy-file`) and log to a specific path (`--audit-log-path`).
    *   **Verify:** Create a new Secret and inspect the audit log file. You should see a detailed entry for the `create` event, including the request and response bodies.

---

### Domain 2: Cluster Hardening

1.  **Scenario: Restrict User Permissions with RBAC**
    *   **Diagnose:** Given a user `dev-user`, show that they can list Secrets in all namespaces.
    *   **Remediate:**
        1.  Create a `Role` named `secret-reader` in the `dev` namespace that only grants `get` and `list` verbs on the `secrets` resource.
        2.  Create a `RoleBinding` to bind the `secret-reader` Role to `dev-user` in the `dev` namespace.
        3.  Remove any `ClusterRoleBindings` that give the user broad permissions.
    *   **Verify:** As `dev-user`, confirm you can `get` secrets in the `dev` namespace but *cannot* `get` secrets in the `kube-system` namespace.

2.  **Scenario: Secure a Service Account**
    *   **Diagnose:** Create a pod and show that a service account token is automatically mounted at `/var/run/secrets/kubernetes.io/serviceaccount/`.
    *   **Remediate:**
        1.  Edit the `default` service account in the namespace and set `automountServiceAccountToken: false`.
        2.  For a specific pod that needs a token, define it with `automountServiceAccountToken: false` in the pod spec and mount a token using a `projected` volume with a specific `audience` and `expirationSeconds`.
    *   **Verify:** Create a new pod and confirm that no token is mounted by default. For the pod with the projected volume, verify that a token exists at the specified mount path.

---

### Domain 3: Minimize Microservice Vulnerabilities

1.  **Scenario: Enforce Pod Security Standards**
    *   **Diagnose:** In a new namespace `secure-ns`, show that you can successfully create a privileged pod (`securityContext: { privileged: true }`).
    *   **Remediate:** Apply a label to the `secure-ns` namespace to enforce the `restricted` Pod Security Standard: `pod-security.kubernetes.io/enforce=restricted`.
    *   **Verify:** Attempt to create the privileged pod again; it should be denied. Create a compliant, non-privileged pod in the namespace; it should be admitted.

2.  **Scenario: Drop Unnecessary Capabilities**
    *   **Diagnose:** Run a pod and use `capsh --decode` to show that it has capabilities like `NET_RAW` by default.
    *   **Remediate:** Apply a `securityContext` to the container that drops `ALL` capabilities and only `add`s the specific ones needed (e.g., `NET_BIND_SERVICE`).
    *   **Verify:** `exec` into the modified pod and run `capsh --decode` again to confirm that only the explicitly added capabilities are present.

---

### Domain 4: System Hardening

1.  **Scenario: Block File Writes with AppArmor**
    *   **Diagnose:** `exec` into a running `busybox` pod and show that you can `touch /tmp/testfile`.
    *   **Remediate:**
        1.  Create a simple AppArmor profile that denies all file writes: `deny /** w,`.
        2.  Load the profile into the kernel using `apparmor_parser`.
        3.  Annotate the pod (or use `securityContext.appArmorProfile`) to apply the new profile.
    *   **Verify:** `exec` into the pod again and attempt to `touch /tmp/testfile`. The operation should be denied.

2.  **Scenario: Isolate a Pod with gVisor**
    *   **Diagnose:** `exec` into a standard `nginx` pod and run `dmesg`. Observe the host kernel messages.
    *   **Remediate:**
        1.  Ensure the `gvisor` `RuntimeClass` is available (`kubectl get runtimeclass`).
        2.  Deploy a new `nginx` pod, setting `runtimeClassName: gvisor` in the pod spec.
    *   **Verify:** `exec` into the gVisor-sandboxed pod and run `dmesg`. The output should be different and indicate it is running under the `gVisor` sandbox.

---

### Domain 5: Supply Chain Security

1.  **Scenario: Scan an Image for High-Severity Vulnerabilities**
    *   **Diagnose:** You are asked to deploy an application using the image `nginx:1.19.0`.
    *   **Remediate:** Use `trivy image nginx:1.19.0 --severity HIGH,CRITICAL` to scan the image for critical and high-severity vulnerabilities.
    *   **Verify:** Generate a report of the findings. Based on the report, choose a more recent, less vulnerable version of the `nginx` image to deploy.

2.  **Scenario: Find Misconfigurations with kube-bench**
    *   **Diagnose:** You need to audit the security of a control plane node.
    *   **Remediate:** Run `kube-bench` on the node. Identify a failing test, for example, a check related to insecure `kube-apiserver` arguments.
    *   **Verify:** Correct the identified misconfiguration in the relevant manifest file (e.g., `/etc/kubernetes/manifests/kube-apiserver.yaml`) and re-run `kube-bench` to confirm the test now passes.

---

### Domain 6: Monitoring, Logging, and Runtime Security

1.  **Scenario: Detect Shell in a Container with Falco**
    *   **Diagnose:** A developer needs to debug a running pod and gets a shell into it.
    *   **Remediate:** Ensure Falco is running. The default rules should already detect this.
    *   **Verify:** `exec` into any pod with `kubectl exec -it <pod> -- /bin/sh`. Check the Falco logs (`journalctl -u falco -f`) and observe the alert for "Terminal shell in container".

2.  **Scenario: Write a Custom Falco Rule**
    *   **Diagnose:** You need to be alerted any time a process reads the file `/etc/shadow` inside a container.
    *   **Remediate:**
        1.  Add a new rule to `/etc/falco/falco_rules.local.yaml`.
        2.  The `condition` should be `open_read and fd.name=/etc/shadow and container.id != host`.
        3.  The `output` should include details like the user, process, and container name.
        4.  Restart Falco: `systemctl restart falco`.
    *   **Verify:** `exec` into a pod and run `cat /etc/shadow`. Check the Falco logs to confirm your custom alert was triggered.
