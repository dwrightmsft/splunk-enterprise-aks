#!/bin/bash
# Install kubectl
az aks install-cli
# Get minio cluster credentials
az aks get-credentials -g $RESOURCEGROUP -n $CLUSTERNAME
# Create License file
echo $LICENSEFILE | base64 -di > /tmp/Splunk.License
# Add license to configmap
kubectl create configmap splunk-licenses --from-file=/tmp/Splunk.License
# Install Splunk Operator
kubectl apply -f $SPLUNKOPERATORURL
kubectl wait --for condition="established" crd --all
# Install Splunk
kubectl apply -f $SPLUNKDEPLOYMENTYAML