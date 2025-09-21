## Objective

The primary goal is to analyze the provided course notes, articles, and presentations to create a tailored set of study aids. This includes practical examples, clear instructions, and mock exam questions to ensure readiness for the CKS exam in a few days.

## 1. Input File Configuration

- **File Types:** Recursively scan the current folder for all `*.md` (Markdown) and `*.pdf` (PDF) files.
- **Content Scope:** Process all text, code blocks, images, and structural elements within these files.

## 2. Analysis Directives

### 2.1. Image Analysis
- **Analyze all images and diagrams** (e.g., `.png`, `.jpg`) embedded in the documents.
- **Identify Kubernetes architecture diagrams**, network policy graphs, and schematics.
- **Extract and interpret text** from screenshots of terminal commands, manifest files (YAML), and logs. For each, explain the purpose and outcome of the commands shown.

### 2.2. Question & Answer Structure Analysis
- **Identify all sections** that are structured as questions, quizzes, or self-assessment tests.
- **Analyze the format of these questions** (e.g., multiple choice, open-ended, scenario-based).
- **Map the topics** of these questions to the official CKS exam domains.

### 2.3. PDF Slide Analysis
- **Process each PDF as a presentation**.
- **Extract key topics, definitions, and concepts** from each slide.
- **Pay special attention to slides containing code snippets, security best practices, and command-line instructions.** Summarize the key takeaways from these slides.

## 3. Output Generation: CKS Exam Prep Kit

Based on the analysis, generate the following in a new folder named `CKS_Exam_Prep`:

### 3.1. `CKS_Examples_and_Scenarios.md`
- **Generate a set of hands-on examples** based on the content. Each example should include:
    - **Scenario:** A brief description of a security challenge (e.g., "Harden a new worker node").
    - **Manifests:** The complete YAML manifests required.
    - **Commands:** The step-by-step `kubectl`, `trivy`, or `falco` commands to complete the task.
    - **Verification:** How to confirm that the task was completed successfully.

### 3.2. `CKS_Key_Instructions.md`
- **Create a concise "cheat sheet"** of instructions and commands.
- **Organize the instructions** by CKS domains:
    - Cluster Setup & Hardening
    - System Hardening
    - Minimizing Microservice Vulnerabilities
    - Supply Chain Security
    - Monitoring, Logging, and Runtime Security
- **Use bullet points and code blocks** for clarity and quick reference.

### 3.3. `CKS_Practice_Exam.md`
- **Develop a set of mock exam questions** that mirror the structure and difficulty of the real CKS exam.
- **Include at least 10-15 scenario-based problems.**
- For each question, provide:
    - **The Problem:** A clear task to be performed in a Kubernetes environment.
    - **A Detailed Solution:** The ideal steps and commands to solve the problem.
    - **An Explanation:** A brief on why this solution is correct and aligns with security best practices.
