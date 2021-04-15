#!/bin/bash
# Install kubectl
az aks install-cli
# Get minio cluster credentials
az aks get-credentials -g $RESOURCEGROUP -n $CLUSTERNAME
# Create License file
LICENSEFILE=$(echo $LICENSEFILE | tr -d '[:blank:]\n')
echo $LICENSEFILE | base64 -d > /tmp/Splunk.License
# Install Splunk Operator
kubectl apply -f $SPLUNKOPERATORURL
kubectl wait --for condition="established" crd --all
# Create namespace
# kubectl create namespace splunk --dry-run -o yaml | kubectl apply -f -
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Namespace
metadata:
  name: splunk
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: splunk:operator:namespace-manager
  namespace: splunk
subjects:
- kind: ServiceAccount
  name: splunk-operator
  namespace: splunk-operator
roleRef:
  kind: ClusterRole
  name: splunk:operator:namespace-manager
  apiGroup: rbac.authorization.k8s.io
EOF
# Add license to configmap
kubectl create configmap --namespace splunk splunk-licenses --from-file=/tmp/Splunk.License --dry-run -o yaml | kubectl apply -f -
# Install Splunk
kubectl apply -f $SPLUNKDEPLOYMENTYAML