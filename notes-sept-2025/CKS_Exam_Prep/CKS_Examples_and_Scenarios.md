
# CKS Examples and Scenarios

## Scenario 1: Harden a new worker node

**Scenario:** A new worker node has been added to the cluster. You need to ensure that it is hardened according to the CIS benchmarks.

**Commands:**
1.  Run `kube-bench` on the new worker node:
    ```bash
    kube-bench --config-dir `pwd`/cfg --config `pwd`/cfg/config.yaml
    ```
2.  Review the output of `kube-bench` and identify the failed checks.
3.  Remediate the failed checks by modifying the kubelet configuration file (`/var/lib/kubelet/config.yaml`) and other relevant files.
4.  Restart the kubelet service: `systemctl restart kubelet`

**Verification:**
- Run `kube-bench` again to verify that all checks pass.

---

## Scenario 2: Isolate a pod with a NetworkPolicy

**Scenario:** You have a pod named `sensitive-pod` in the `default` namespace. You need to create a NetworkPolicy that denies all ingress traffic to this pod except from pods with the label `app=client`.

**Manifests:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-except-client
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: sensitive-pod
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: client
```

**Commands:**
1.  Apply the NetworkPolicy: `kubectl apply -f network-policy.yaml`

**Verification:**
1.  Create a client pod with the label `app=client` and try to connect to `sensitive-pod`. The connection should be successful.
2.  Create another pod without the label `app=client` and try to connect to `sensitive-pod`. The connection should fail.

---

## Scenario 3: Scan a running container image for vulnerabilities

**Scenario:** You need to scan the container image of a running pod for high-severity vulnerabilities.

**Commands:**
1.  Get the image name of the running pod: `kubectl get pod <pod-name> -o jsonpath='{.spec.containers[0].image}'`
2.  Scan the image with Trivy: `trivy image <image-name> --severity HIGH`

**Verification:**
- Review the output of Trivy to see the list of high-severity vulnerabilities.

---

## Scenario 4: Configure an audit policy

**Scenario:** You need to configure an audit policy to log all secret creations and modifications.

**Manifests:**
```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: RequestResponse
  resources:
  - group: ""
    resources: ["secrets"]
  verbs: ["create", "patch", "update"]
```

**Commands:**
1.  Save the audit policy to a file (e.g., `audit-policy.yaml`).
2.  Modify the kube-apiserver manifest (`/etc/kubernetes/manifests/kube-apiserver.yaml`) to add the following flags:
    ```yaml
    - --audit-policy-file=/etc/kubernetes/audit-policy.yaml
    - --audit-log-path=/var/log/kubernetes/audit.log
    ```
3.  Restart the kube-apiserver.

**Verification:**
1.  Create or modify a secret.
2.  Check the audit log (`/var/log/kubernetes/audit.log`) to see if the event was logged.

---

## Scenario 5: Secure Docker Daemon

**Scenario:** You need to secure the Docker daemon on a worker node.

**Commands:**
1.  Remove any non-root users from the `docker` group: `sudo gpasswd -d <user> docker`
2.  Ensure the Docker socket is owned by `root:root`: `sudo chown root:root /var/run/docker.sock`
3.  Disable the TCP socket for the Docker daemon by editing the systemd service file (`/lib/systemd/system/docker.service`) and removing the `-H tcp://0.0.0.0:2375` flag.
4.  Reload the systemd daemon and restart Docker: `sudo systemctl daemon-reload && sudo systemctl restart docker`

**Verification:**
-  Ensure that you can no longer connect to the Docker daemon via the TCP socket.
