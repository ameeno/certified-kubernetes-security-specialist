## RBAC

ultimately, there are users that can be authenticated using keys and tokens ca certs ect however you authenticte them (kubeconfig file))

next you can create roles, cluster roles, role bindings, cluster role bindings

you grant permissions within roles, to apigroups, resources and verbs to a role.

apigroups can be looked up on the kubernetes api. resources can also be looked up, as can relevant verbs.

when you associate users with roles, you are giving them permissions to perform actions on the cluster.

a good couple of comamnds to check permissions are:
```bash
kubectl auth can-i create deployments
kubectl auth can-i create pods
```

## roles/role bindings
single namespace permissions.
example:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list","create", "delete"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: john
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

## cluster roles cluster role bindings.
cluster wide permissions
Due to the fact that cluster roles and cluster role bindings are cluster wide, they can give access to cluster wide resources like listing namespaces, or nodes, anything cluster wide and not namespaced,
as well as namespaced resources like pods.

example

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list","create", "delete"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: john
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```
Another interesting point is you can make cluster wide ClusterRoles, but then create namespaced Rolebindings associated with a ClusterRole. this results in a namespaced permissions set, but centralised management of roles.


## user accounts vs service accounts
user accounts are for users, service accounts for applications. pods can mount tokens as every service has a service account, and using these tokens they can authenticate to the k8s api. and this can be dangeous.

by default each namespace has a default service account and automounted to containers. you can set automountingto false in the service account on both pod spec or serviceaccount spec.

whenever there is a clash between pod spec and sa spec, the pod spec takes presedence


## upgrading kubeadm servers:
1. find latest version to upgrade to.
2. unhold kubeadm binary from package manager apt unhold.
3. download latest kubeadm binary / install (using apt-get).
4. perform upgrade plan.
5. choose the version to upgrade to and the appropriate run command
6. upgrade kubectl and kubelet binaries
7. restart services


