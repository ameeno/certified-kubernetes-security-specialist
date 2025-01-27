cks notes:

## Authentication, Authorization, Admissions controller
Ingress is a resource that allows you to expose services outside of the cluster.
there are three steps between apiserver doing stuff and you.
authentication, authorization, and Admissions controller.

Authentication: - and options.
Token Auth (CSV file of tokens)
downsides of token auth (csv file with tokens):
1 tokens stored in plain text on api server (bad if someone has access)
2 tokens cannot be revoked  or rotated without restarting apiserver.
3 hence it is not recommended to use this type of authentication.

x509 certificate authentication (certificates signed by trusted ca certificate/key)
downsides:
1 private key is stored on insecure unencrypted media usually (local disk for example) - so can be accessed
2 Certificates are generally long-lived (unless you expire quickly, Kubernetes does not support certificate revocation area.
3 groups are associated with an organization in a a certificate, if you want to change the groups, you will need to issue a new certificate. - basically when a certificate is generated, we specify a /CN=Common_Name/O=Organization ie group. this cannot be changed ona  cert, a new cert will be needed to change groups. but the old cert would not be revoked!!!!

OpenID Connect based authentication.
A Third party Identity Provider that is used for authentication (for example, OKTA or something like that)
the kube-apiserver must trust the identity provider.

For identity providers, you often use oidc url, clientid and token, but it is outside of scope of exam to set one up as its a complicated topic and sso can be used in different wys, for example eks will allow iam auth.


Authorization:
After a request is authenticated using the methods above, the request must next be authorized.
there are a few main authorization options, example: AlwaysDeny, AlwaysAllow, RBAC, Node.
AlwaysDeny: Blocks all requests, and is used for tests
AlwaysAllow: Allows all requests - (use if you do not need authorization)
RBAC: Allows creation and storage of policies using the Kubernetes API
ABAC: Attribute-based access control
Webhook: A pluggable interface for custom authorization logic
Node: A special purpose authorization mode that grants permissions to kubelets.

They are configured by passing the flag --authorization-mode to the apiserver on startup. the default is "AlwaysAllow"

The most popular authorization mode is RBAC. - Role based access control.
Any user that is part of the group system:masters has full admin access to the cluster, and everyone else is restricted.
Rbac has ClusterRoles and roles to grant permissions, but even if you delete all clusterRoles and roles, you will still have full admin access to the cluster( retain full access if part of group).

for Certificate based auth, you can use the following command to get the user that is authenticated to system:masters:

```bash
cd /root/certificates
openssl genrsa -out bob.key 2048
openssl req -new -key bob.key -subj "/CN=bob/O=system:masters" -out bob.csr
openssl x509 -req -in bob.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out bob.crt -extensions v3_req  -days 1000
```

and then you can use certificate with:

```bash
kubectl get secret --server=https://127.0.0.1:6443 --client-certificate /root/certificates/bob.crt --certificate-authority /root/certificates/ca.crt --client-key /root/certificates/bob.key
```

**WARNING** combining certificate auth with a group of system:masters is highly dangerous for the reasons mentiond in x509 certification downsides. as it is not easy to revoke those certificates and it is not easy to rotate them. - basically gives super power to whomever has those certs.



## Encryption of data

By Default, Etcd stores data in plain text. While we have worked on securing access to Etcd using TLS certificates, tls and encryption during communication, and also certificates to access the API-Server to prevent man in the middle attacks, we have not encrypted our data yet.

This can be demonstrated by creating a secret:
```bash
kubectl create secret generic new-secret -n default --from-literal=user=secretpassword --server=https://127.0.0.1:6443 --client-certificate /root/certificates/bob.crt --certificate-authority /root/certificates/ca.crt --client-key /root/certificates/bob.key
```

and then we can now dump out that secret from etcd from the db directly by doing:
```bash
cd /root/certificates
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --insecure-skip-tls-verify  --insecure-transport=false --cert ./apiserver.crt --key ./apiserver.key get /registry/secrets/default/new-secret | hexdump -C
```
we can also grep for the data:

```bash
cd /var/lib/etcd
grep -R "secretpassword" .
```

which will show us the files (so the data is not encrypted.)

however if we create an EncryptionConfig object v1: we can set the apiserver to encrypt the data that goes into etcd., Remember this object type EncryptionConfig!!!

there are multiple types of providers that we can use and keys and identity types.

the kube-apiserver accepts a flag called `--encryption-provider-config` that points to a file that contains the encryption configuration.

```bash
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
echo $ENCRYPTION_KEY

# Create Encryption Config:

cat > encryption-at-rest.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
```

and then set the api-server to use the encryption token to encrypt the data that goes into etcd:

```bash
mkdir /var/lib/kubernetes
mv encryption-at-rest.yaml /var/lib/kubernetes
nano /etc/systemd/system/kube-apiserver.service # add flag: --encryption-provider-config=/var/lib/kubernetes/encryption-at-rest.yaml

systemctl daemon-reload
systemctl restart kube-apiserver
systemctl status kube-apiserver
```
Now we wont be able to dump out the data from etcd or grep for it in the etcd files.
etcd works as normal and doesnt really care what goes into it as its a key value database, but the apiserver will encrypt all the data it stores.

### Encryption providers for kubernetes:
1. Identity provider: Encryption type: None, Strength: None Speed: None
2. aescbc: Encryption type: AES-CBC with PKCS#7 padding : Strength: Strongest, SPeed: Fast.
3. secretbox: Encryption type: XSalsa20-Poly1305 : Strength: Strong, Speed: Faster.
4. kms: Encryption type: Key Management Service : Strength: Strongest, Speed: Fast. - Uses external key management tools.

by default, the idenity provider is used to protect secrets in etcd (none basically)

you can make use of a KMS provider for additional security.

If encryption is added later, older secrets will still be in unecrypted form.


## Auditing.

Auditing provides a security relevant chronological set of records, documenting the sequence of actions in a cluster.

The cluster audits activites generated by applications that use the Kubernetes api, and by the control plane itself.

* What happend?
* when did it happen?
* Who initiated it?
* on what did it happen?
* from where was it initiated?
* to where was it going?


Auditing policy levels are as follows:

| Audit Levels | Description |
| --- | --- |
| None | don't log events that match this |
| Metadata | log metadata (requesting user, timestamp) but not request or response body |
| Request | Logs event metadata and request body, but not response body |
| RequestResponse | Log event metadata, request and response bodies |


## Kubeadm setup

Installed using ansible playbook and terraform on proxmox.
Code in other repo folder: cks-proxmox-lab

## Taints & Tolerations.

Taints are like blockers for scheduling on a node, tolerations are like a pass to overcome the taint.

the types of taints are: NoSchedule, PreferNoSchedule, NoExecute.
NoSchedule: Prevents scheduling of NEW Pods: Do not schedule on this node with specific taint, unless tolerated.
PreferNoSchedule: Try Not to schedule on this node unless tolerated
NoExecute: Evicts existing pods and prevents new pods on this node.

to taint a node:

```bash
kubectl taint node <node-name> key=value:NoSchedule
# node/<node-name> tainted
# taint consists of key, value (optional), and effect
```

for tolerations:

to remove a taint:
```bash
kubectl taint node <node-name> key=value:NoSchedule-
```

to tolerate a taint:
```yaml
spec:
  tolerations:
  - key: "key1"
    operator: "Equal"
    value: "value1" # optional
    effect: "NoSchedule"
---
spec:
  tolerations:
  - key: "key1"
    operator: "Exists"
    effect: "NoSchedule"
```

## Kubelet security

important flags:
--anonymous-auth=false # disables anonymous auth (recommended)
--authorization-mode=Node,RBAC,Webhook # make sure it is never set to: AllwaysAllow, Webhook
--client-ca-file=<filename> # adds the ca bundle to verify clients using certificates
--read-only-port # make sure this is *NOT* part of kubelet config To make a read only api port


the Kubelets need to be part of the system:nodes:<node_name> Common name certificate, and the organization needs to be 'system:nodes' - check that using `openssl x509 -in <certificate file> -text -noout`
to get info on the certificate and make sure the correct certificate is being used. - to ensure the node/kubelet is validated.
If the kubelet config is not secure, you have backdoor access to all pods and other information.
kubelet config file is stored at `/var/lib/kubelet/config.yaml` - check that for errors.


## verify platform binaries
use `sha512sum filename.tar.gz` to verify if the hash matches the hash on kubernetes website
if sha512sum is missing you can install `hashalot` package


## Kubernetes Ingress
Typically an ingress controller sets up a loadbalancer with the cloud provider, and a nodeport into the cluster with a service. and then routes traffic inside the cluster based upon rules that target the load balancer.
nginx ingress controller is a popular ingress controller.
the controller will point traffic to the services inside the cluster, and the load balancer will point traffic to the controller.
and the service will point traffic to the pods.

## overview of ingress with TLS
Out of the box, traffic to load balancer is not secured via tls and it uses HTTP traffic which is suspectable to MITM attacks as traffic is plaintext.
this should be avoided.
Points to note, certificates and keys are stored in k8s as part of secrets, and you can store ssl certificates and keys as part of secrets for k8s

practical done for creating certificates and incgress tls might be required in exam.


## RBAC
