1/ Falco: Given: 3 pods nvidia, cpu, ollama are accessing /dev/mem and we need to scale down replica to zero for those pod
2/ Istio: apply mtls sidecar
https://istio.io/latest/docs/tasks/security/authentication/mtls-migration/#lock-down-to-mutual-tls-by-namespace

https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#deploying-an-app

3/ Ingress with tls: Given a secret tls and create an Ingress tls. Also redirect http request to https (should use ingressClassName: nginx with the annotation ssl-redirect
https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/

4/ Upgrade worker node from 1.33.0 -> 1.33.1 (remember to drain node because there's a running pod on the compute-0)

5/ Docker daemon secure:
Require 1: remove user “develop” from group docker
Require 2: Then chown root:root of Docker sock /var/run/docker.sock
Require 3: Docker daemon change to unix from tcp ( /lib/systemd/system/docker.service)

6/ Bom: There’s a pod alpine with 3 containers using image alpine with different version 3.20.0, 3.19.6 and 3.16.1.
Require 1: Check with container has libcrypto3 version x.y.z and change the deployment yaml file remove that container, then redeploy
Require 2: Generate a SPDX report write to file.

7/ Static file analysic:
Given: A long Dockerfile and a deploy yaml file.
Require 1: change one line only and DO NOT add/remove any lines, dont build the image (it mentioned in the question) → Change USER root to USER couchdb.
Require 2: change one line only and DO NOT add/remove any lines → Change readOnlyRootFilesystem from false to true.
Istio
Installing the Sidecar
Install the Istio sidecar in application pods automatically using the sidecar injector webhook or manually using istioctl CLI.
The Istio sailboat logo
Istio
Mutual TLS Migration
Shows you how to incrementally migrate your Istio services to mutual TLS.
The Istio sailboat logo
8/ Secret TLS:
Given: A deployment yaml file, a cert file and a key file
Require: Create a tls secret in a namespace → apply it to the deployment yaml file and apply it.
9/ Projected volume and SA:
Given: an SA and a deployment yaml file.
Require 1: Change the SA automountServiceAccountToken to false
Require 2: Using projected volume for the deployment under /var/run/secrets/kubernestes.io/serviceaccount/token
10/ Kube-bench
Fix 3 issues only, not taking much time.
Kubelet
Controller manager
Etcd
11/ Auditing
12/ ImagePolicyWebhook
13/ Network policies: create 2 policies (no CiliunmNetworkPolicies)
14/ PSS: Try to fix the given deployment yaml file to make the pod running. Check replicaset event.
15/ Kube-apiserver: change the anonymous-auth flag and delete a clusterrolebinding system:anonymous
16/ Seccomp profile

