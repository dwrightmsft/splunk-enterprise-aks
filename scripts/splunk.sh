#!/bin/bash
# Install kubectl
az aks install-cli
# Get minio cluster credentials
az aks get-credentials -g $RESOURCEGROUP -n $CLUSTERNAME
# Create License file
LICENSEFILE=$(echo $LICENSEFILE | tr -d '[:blank:]\n')
echo $LICENSEFILE | base64 -d > /tmp/Splunk.License
# Create namespace
kubectl create namespace splunk --dry-run -o yaml | kubectl apply -f -
# Add license to configmap
kubectl create configmap --namespace splunk splunk-licenses --from-file=/tmp/Splunk.License --dry-run -o yaml | kubectl apply -f -
# Install Splunk Operator
kubectl apply -f $SPLUNKOPERATORURL
kubectl wait --for condition="established" crd --all
# Install Splunk
kubectl apply -f $SPLUNKDEPLOYMENTYAML