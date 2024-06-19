#!/bin/bash
# Set GCP variables
GCP_PROJECT="<project>"
GCP_ZONE="<zone>"
GKE_CLUSTER_NAME="<cluster-name>"
#
PIPE_K8S_USER="pipelines-k8s-user"
NAMESPACE="jfrog-platform"
# user
PIPE_K8S_USER_TOKEN=$(kubectl get secret ${PIPE_K8S_USER} -n ${NAMESPACE} -o "jsonpath={.data.token}" | base64 -D)
# server
SERVER_IP=$(kubectl config view --minify --flatten -o jsonpath='{.clusters[0].cluster.server}')
SERVER_CA=$(kubectl config view --minify --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')
# Create kubeconfig template
cat > sa_kubeconfig.yaml <<EOF
apiVersion: v1
kind: Config
current-context: ${GKE_CLUSTER_NAME}
contexts:
- context:
    cluster: ${GKE_CLUSTER_NAME}
    namespace: ${NAMESPACE}
    user: ${PIPE_K8S_USER}
  name: ${GKE_CLUSTER_NAME}
clusters:
- name: ${GKE_CLUSTER_NAME}
  cluster:
    server: "${SERVER_IP}"
    certificate-authority-data: "${SERVER_CA}"
users:
- name: ${PIPE_K8S_USER}
  user:
    token: ${PIPE_K8S_USER_TOKEN}
    name: ${PIPE_K8S_USER}
EOF
# Create secret for kubeconfig template
KUBECONFIG=$(cat sa_kubeconfig.yaml | base64 )
cat > kubeconfig-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: k8s-pool-kubeconfig
  namespace: ${NAMESPACE}
type: Opaque
data:
  kubeconfig: ${KUBECONFIG}
EOF
# Deploy
kubectl apply -f kubeconfig-secret.yaml
