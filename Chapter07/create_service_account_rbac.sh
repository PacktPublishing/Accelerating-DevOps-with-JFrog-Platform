#!/bin/bash
PIPE_K8S_USER="pipelines-k8s-pool"
NAMESPACE="jfrog-platform"
# Create ServiceAccount and ClusterRoleBinding template
cat > pipelines_k8s_sa_rbac.yaml <<EOF
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${PIPE_K8S_USER}
  namespace: ${NAMESPACE}
---
apiVersion: v1
kind: Secret
metadata:
  name: pipelines-k8s-pool
  namespace: ${NAMESPACE}
  annotations:
    kubernetes.io/service-account.name: ${PIPE_K8S_USER}
type: kubernetes.io/service-account-token
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ${PIPE_K8S_USER}-clusterrole
rules:
  - apiGroups: ["", "extensions", "apps"]
    resources:
    - deployments
    - persistentvolumes
    - persistentvolumeclaims
    - pods
    - deployments/scale
    - secrets
    - configmaps
    verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${PIPE_K8S_USER}-clusterrole-binding
subjects:
  - kind: ServiceAccount
    name: ${PIPE_K8S_USER}
    namespace: ${NAMESPACE}
roleRef:
  kind: ClusterRole
  name: ${PIPE_K8S_USER}-clusterrole
  apiGroup: rbac.authorization.k8s.io
EOF
# Deploy
kubectl apply -f pipelines_k8s_sa_rbac.yaml
