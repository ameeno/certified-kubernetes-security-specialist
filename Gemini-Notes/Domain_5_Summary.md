
# Domain 5: Supply Chain Security Summary

## Core Concepts

*   **Image Vulnerability Scanning:** Using tools like `Trivy` to scan container images for known vulnerabilities (CVEs). This is a critical step in ensuring that you are not deploying insecure software into your cluster.
*   **Static Analysis:** Analyzing Kubernetes manifest files for security misconfigurations before they are deployed. Tools like `checkov` can identify issues such as running privileged containers or missing security contexts.
*   **Dockerfile Best Practices:** Writing secure Dockerfiles to create hardened container images. Key practices include:
    *   Using minimal base images (e.g., `alpine`).
    *   Running as a non-root user (`USER <non-root-user>`).
    *   Avoiding unnecessary packages and tools.
    *   Granting minimal file permissions (`chmod`, `chown`).
*   **Securing the Docker Daemon:**
    *   The Docker daemon API should not be exposed over an unauthenticated TCP socket, as this can allow anyone with network access to control the Docker engine.
    *   If remote access is needed, it must be secured using TLS for authentication and encryption.
*   **CIS Benchmarks:** Using tools like `kube-bench` to audit your Kubernetes cluster against the CIS (Center for Internet Security) benchmarks, which provide prescriptive guidance for establishing a secure configuration posture.
*   **SBOM (Software Bill of Materials):** Generating a list of all components, libraries, and dependencies within a piece of software. Tools like `Trivy` and `bom` can generate SBOMs for container images, which is essential for tracking vulnerabilities and managing supply chain risk.

## Essential Commands

*   **`trivy`:**
    ```bash
    # Scan a container image for vulnerabilities
    trivy image <image-name>:<tag>

    # Generate an SBOM in SPDX format
    trivy image --format spdx-json --output <output-file.spdx.json> <image-name>:<tag>

    # Scan an SBOM for vulnerabilities
    trivy sbom <sbom-file.spdx.json>
    ```

*   **`checkov`:**
    ```bash
    # Scan a Kubernetes manifest file
    checkov -f <manifest.yaml>
    ```

*   **`kube-bench`:**
    ```bash
    # Run the CIS benchmark tests on a Kubernetes node
    kube-bench
    ```

*   **`docker` & `dockerd`:**
    ```bash
    # Build a Docker image
    docker build -t <image-name>:<tag> .

    # Run the Docker daemon with a specific DNS (example)
    dockerd --dns=8.8.8.8
    ```

*   **`openssl` (for securing Docker daemon):**
    ```bash
    # Generate a CA
    openssl genpkey -algorithm RSA -out ca-key.pem
    openssl req -new -x509 -key ca-key.pem -subj "/CN=MyDockerCA" -out ca.pem

    # Generate server and client certificates signed by the CA
    # (See domain-5-supply-chain-security/docker-tls.md for full steps)
    ```

*   **`bom`:**
    ```bash
    # Generate an SBOM for a container image
    bom generate spdx-json --image <image-name>:<tag> --output <output.spdx.json>
    ```
