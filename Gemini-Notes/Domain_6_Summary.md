
# Domain 6: Monitoring, Logging, and Runtime Security Summary

## Core Concepts

*   **Audit Logging:** Configuring the Kubernetes API server to generate audit logs that record all requests. This is essential for security analysis, incident response, and compliance. Audit policies allow you to specify what gets logged and at what level (e.g., `Metadata`, `Request`, `RequestResponse`).
*   **Falco:** A runtime security tool that detects anomalous activity in your applications and containers. Falco works by:
    *   Monitoring system calls using a kernel module or eBPF probe.
    *   Matching these system calls against a set of predefined and custom rules.
    *   Generating alerts when a rule is violated.
*   **Falco Rules:** The logic that Falco uses to detect suspicious behavior. Key components of a Falco rule include:
    *   `rule`: The name of the rule.
    *   `desc`: A description of the rule.
    *   `condition`: The core logic that triggers the alert, based on system events (e.g., `evt.type = execve`), process names (`proc.name`), container information (`container.id`), etc.
    *   `output`: The format of the alert message.
    *   `priority`: The severity of the alert (e.g., `CRITICAL`, `WARNING`, `INFO`).
    *   `macros` and `lists` can be used to simplify and reuse conditions.
*   **Sysdig:** A powerful open-source tool for system-level exploration and troubleshooting. It can be used to capture, filter, and analyze system calls and other events, which is useful for understanding what Falco is monitoring under the hood.

## Essential Commands

*   **`kube-apiserver` (Audit Flags):**
    ```bash
    --audit-policy-file=<path/to/policy.yaml>
    --audit-log-path=<path/to/audit.log>
    --audit-log-maxage=<days>
    --audit-log-maxbackup=<files>
    --audit-log-maxsize=<megabytes>
    ```

*   **Audit Policy File Example:**
    ```yaml
    apiVersion: audit.k8s.io/v1
    kind: Policy
    rules:
      # Log all requests for secrets at the RequestResponse level
      - level: RequestResponse
        resources:
        - group: ""
          resources: ["secrets"]

      # Don't log requests from the kube-controller-manager for secrets
      - level: None
        users: ["system:kube-controller-manager"]
        resources:
        - group: ""
          resources: ["secrets"]
    ```

*   **`falco` & `systemctl`:**
    ```bash
    # Check the status of the Falco service
    systemctl status falco

    # Restart the Falco service after changing rules
    systemctl restart falco

    # View Falco logs in real-time
    journalctl -u falco -f

    # Run Falco manually (for debugging)
    falco
    ```

*   **Falco Rule Example:**
    ```yaml
    - rule: Detect shell running in a container
      desc: A shell was spawned in a container with an attached terminal.
      condition: >
        spawned_process and container and
        proc.name in (bash, sh, zsh) and
        proc.tty != 0
      output: >
        Shell spawned in container (user=%user.name container_id=%container.id container_name=%container.name proc_name=%proc.name)
      priority: WARNING
    ```

*   **`sysdig`:**
    ```bash
    # General system call monitoring
    sysdig

    # Filter by process name
    sysdig proc.name=nginx

    # Filter for processes running inside containers
    sysdig container.id != host

    # Use a chisel to see top processes by CPU
    sysdig -c topprocs_cpu
    ```
