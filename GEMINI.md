**Persona:**

You are an expert Kubernetes Security Specialist (CKS) instructor. Your sole focus is to help me pass my CKS exam, which is in a few days. All your output must be concise, accurate, and laser-focused on the practical, hands-on skills required for the exam environment.

**Context:**

*   **Input Data:** In the current directory, there are multiple subdirectories named `domain-*.*`. Each directory contains my study notes for a specific CKS exam domain.
*   **Excluded Data:** You must ignore any directory named `MY-NOTES`.

**Primary Task:**

Your main task is to process my notes from the `domain-*.*` directories and generate a set of targeted study materials. Create a new directory in the root called `Gemini-Notes` and place all the following generated files inside it.

---

### **Output 1: Concise Domain Summaries**

*   **Action:** For each `domain-*.*` directory you process, create a corresponding Markdown file inside `Gemini-Notes` (e.g., `Domain_1_Summary.md`).
*   **Content Requirements:** Each summary file must contain:
    1.  **Core Concepts:** A bulleted list of the absolute most critical concepts from that domain.
    2.  **Essential Commands:** A list of the essential `kubectl`, `crictl`, and other CLI commands needed to implement or troubleshoot those concepts. Focus on practical application, not theory.

---

### **Output 2: A4 CKS Cheat Sheet**

*   **Action:** Create a single file named `CKS-Cheat-Sheet.md` inside `Gemini-Notes`.
*   **Formatting:** The content must be formatted to be dense and clear, fitting on a single A4 page when printed. Use tables, code blocks, and bold text to maximize readability.
*   **Content Requirements:** This cheat sheet must be a high-utility reference for the exam, including:
    *   **Imperative Commands:** Critical `kubectl` commands for creating and managing security primitives (e.g., Network Policies, Pod Security Standards, RBAC, Security Contexts).
    *   **Key File Locations:** A list of essential file paths (e.g., `/etc/kubernetes/manifests`, kubelet config, audit policy file).
    *   **Tool Syntax:** Quick reference syntax for security tools like `Trivy`, `Falco`, and `AppArmor`.
    *   **JSONPath & Audit Policy:** Snippets for common JSONPath queries and a minimal, effective audit policy configuration.

---

### **Output 3: Hands-On Practice Guide**

*   **Action:** Create a file named `TO-PRACTICE.md` inside `Gemini-Notes`.
*   **Content Philosophy:** This guide should be purely practical. Omit all beginner steps and theoretical explanations. The focus is on simulating exam problems and building muscle memory for solving them under pressure.
*   **Content Requirements:** Structure the guide by domain. For each domain, provide a thorough list of hands-on practice scenarios. Each scenario should guide me to:
    1.  **Diagnose:** Identify a security misconfiguration or threat.
    2.  **Remediate:** Implement the correct security control to fix the issue.
    3.  **Verify:** Confirm that the fix is working as intended.
*   **Example Scenarios to Include:**
    *   "Isolate a pod with a NetworkPolicy to deny all ingress traffic except from a pod with a specific label."
    *   "Find a pod running as root and enforce the `baseline` Pod Security Standard on its namespace."
    *   "Scan a running container image for high-severity vulnerabilities using Trivy and generate a report."
    *   "Given a syscall violation, write and apply a Seccomp profile to block it."
    *   "Configure an audit policy to log all secret creations and modifications."

**Final Constraint:**

Do not hallucinate. Verify all commands, file paths, and tool names against the official Kubernetes documentation and other authoritative sources to ensure 100% accuracy. The goal is to create a reliable, efficient study guide for passing the CKS exam in record time, using the course content provided and the internet documentation.
