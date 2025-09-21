16 questions and I will share some

Falco: Given: 3 pods nvidia, cpu, ollama are accessing /dev/mem and we need to scale down replica to zero for those pod

Istio: apply mtls sidecar https://istio.io/latest/docs/tasks/security/authentication/mtls-migration/#lock-down-to-mutual-tls-by-namespace https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#deploying-an-app

permalinkembedsavereportreply

[–]vietnam_lever

[S] 1 point 1 month ago

Ingress with tls: Given a secret tls and create an Ingress tls. Also redirect http request to https (should use ingressClassName: nginx with the annotation ssl-redirect https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/



[–]vietnam_lever

[S] 1 point 1 month ago

Docker daemon secure: Require 1: remove user “develop” from group docker Require 2: Then chown root:root of Docker sock /var/run/docker.sock Require 3: Docker daemon change to unix from tcp ( /lib/systemd/system/docker.service)



[–]vietnam_lever

[S] 1 point 1 month ago

Bom: There’s a pod alpine with 3 containers using image alpine with different version 3.20.0, 3.19.6 and 3.16.1.
Require 1: Check with container has libcrypto3 version x.y.z and change the deployment yaml file remove that container, then redeploy
Require 2: Generate a SPDX report write to file.



[–]vietnam_lever

[S] 1 point 1 month ago

Static file analysic: Given: A long Dockerfile and a deploy yaml file.
Require 1: change one line only and DO NOT add/remove any lines, dont build the image (it mentioned in the question) → Change USER root to USER couchdb.
Require 2: change one line only and DO NOT add/remove any lines → Change readOnlyRootFilesystem from false to true.



[–]vietnam_lever

[S] 1 point 1 month ago

Secret TLS: Given: A deployment yaml file, a cert file and a key file Require: Create a tls secret in a namespace → apply it to the deployment yaml file and apply it.



[–]vietnam_lever

[S] 1 point 1 month ago

Projected volume and SA: Given: an SA and a deployment yaml file.

Require 1: Change the SA automountServiceAccountToken to false

Require 2: Using projected volume for the deployment under /var/run/secrets/kubernestes.io/serviceaccount/token



[–]Wild_Wafer313

 1 point 1 month ago

Was Require 1 and Require 2 in the same Task ?

I didn't understand the Require 2 when I was taking the exam.
When I remember correctly, the Task descriptions was something like: "mount the token which can be found under /var/run/security/token/<dont-remember-the-rest> as projected Volume. "
Does it mean "now that the token is not auto-mounted anymore, mount it manually by using a projected volume" ?



[–]vietnam_lever

[S] 1 point 1 month ago

- Kube-bench Fix 3 small issues
- Auditing
- ImagePolicyWebhook
- Network policies: create 2 policies (no CiliunmNetworkPolicies)
- PSS: Try to fix the given deployment yaml file to make the pod running. Check replicaset event.
- Kube-apiserver: change the anonymous-auth flag and delete a clusterrolebinding system:anonymous
- Seccomp profile apply
- Upgrade worker node from 1.33.0 to 1.33.1


