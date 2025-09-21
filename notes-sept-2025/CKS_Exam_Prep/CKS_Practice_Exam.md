
# CKS Practice Exam

This practice exam contains a set of scenario-based questions similar to what you might encounter in the CKS exam.

---

### Question 1: Falco Rule for /dev/mem Access

**Problem:** Three pods named `nvidia`, `cpu`, and `ollama` are accessing `/dev/mem`. Create a Falco rule to detect this behavior and then scale down the replicas of these pods to zero.

**Detailed Solution:**
1.  **Create a Falco rule:** Add the following rule to `/etc/falco/falco_rules.local.yaml`:
    ```yaml
    - rule: Detect /dev/mem access
      desc: Detects access to /dev/mem
      condition: open_read and fd.name=/dev/mem and container.id != host
      output: "/dev/mem was opened for reading by a container (user=%user.name command=%proc.cmdline container_id=%container.id container_name=%container.name image=%container.image.repository)"
      priority: WARNING
    ```
2.  **Restart Falco:** `systemctl restart falco`
3.  **Identify the deployments:** Find the deployments managing the pods `nvidia`, `cpu`, and `ollama`.
4.  **Scale down the deployments:**
    ```bash
    kubectl scale deployment <deployment-name-nvidia> --replicas=0
    kubectl scale deployment <deployment-name-cpu> --replicas=0
    kubectl scale deployment <deployment-name-ollama> --replicas=0
    ```

**Explanation:** This solution first detects the suspicious behavior using a custom Falco rule and then mitigates the threat by scaling down the affected pods.

---

### Question 2: Ingress with TLS and HTTP to HTTPS Redirect

**Problem:** You are given a TLS secret named `my-tls-secret`. Create an Ingress resource that uses this secret for TLS termination and redirects HTTP traffic to HTTPS.

**Detailed Solution:**
1.  **Create the Ingress manifest:**
    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: my-ingress
      annotations:
        nginx.ingress.kubernetes.io/ssl-redirect: "true"
    spec:
      ingressClassName: nginx
      tls:
      - hosts:
        - myapp.com
        secretName: my-tls-secret
      rules:
      - host: myapp.com
        http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 80
    ```
2.  **Apply the Ingress:** `kubectl apply -f ingress.yaml`

**Explanation:** This Ingress resource is configured to use the provided TLS secret and the `ssl-redirect` annotation to enforce HTTPS.

---

### Question 3: Upgrade a Worker Node

**Problem:** Upgrade the worker node `compute-0` from version `1.33.0` to `1.33.1`. There is a running pod on this node.

**Detailed Solution:**
1.  **Drain the node:** `kubectl drain compute-0 --ignore-daemonsets`
2.  **Upgrade kubeadm:** `apt-get install -y kubeadm=1.33.1-00`
3.  **Upgrade the kubelet and kubectl:** `apt-get install -y kubelet=1.33.1-00 kubectl=1.33.1-00`
4.  **Restart the kubelet:** `systemctl restart kubelet`
5.  **Uncordon the node:** `kubectl uncordon compute-0`

**Explanation:** This solution follows the standard procedure for upgrading a worker node, ensuring that the running pod is safely evicted before the upgrade.

---

### Question 4: Secure Docker Daemon

**Problem:** Secure the Docker daemon on a worker node by removing the `develop` user from the `docker` group, setting the correct ownership for the Docker socket, and disabling the TCP socket.

**Detailed Solution:**
1.  **Remove user from docker group:** `gpasswd -d develop docker`
2.  **Set ownership of Docker socket:** `chown root:root /var/run/docker.sock`
3.  **Disable TCP socket:** Edit `/lib/systemd/system/docker.service` and remove the `-H tcp://0.0.0.0:2375` flag.
4.  **Reload and restart Docker:** `systemctl daemon-reload && systemctl restart docker`

**Explanation:** This solution hardens the Docker daemon by restricting access to the Docker socket and disabling remote access.

---

### Question 5: SBOM Analysis and Remediation

**Problem:** A deployment named `alpine-app` is running three containers with different versions of the `alpine` image. Identify the container that has the `libcrypto3` library with version `x.y.z`, remove it from the deployment, and generate an SPDX report for the remaining images.

**Detailed Solution:**
1.  **Identify the container:** Use `trivy` or another SBOM tool to inspect the images and find the one with the specified `libcrypto3` version.
2.  **Edit the deployment:** `kubectl edit deployment alpine-app` and remove the container with the vulnerable image.
3.  **Generate SPDX report:** Use the `bom` tool to generate an SPDX report for the remaining images.
    ```bash
    bom generate -f <image1> -o report1.spdx.json
    bom generate -f <image2> -o report2.spdx.json
    ```

**Explanation:** This solution demonstrates how to use SBOM tools to identify and remediate vulnerabilities in container images.
