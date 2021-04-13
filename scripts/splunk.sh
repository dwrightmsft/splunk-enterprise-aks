#!/bin/bash
# Install kubectl
az aks install-cli
# Get minio cluster credentials
az aks get-credentials -g $RESOURCEGROUP -n $CLUSTERNAME
# Create namespace
kubectl create namespace splunk
# Create License file
echo $LICENSEFILE | base64 -di > Splunk.License
# Add license to configmap
kubectl create configmap splunk-licenses --from-file=Splunk.License
# Install Splunk Operator
kubectl apply -f $SPLUNKOPERATORURL
kubectl wait --for condition="established" crd --all
# Install Splunk
kubectl apply -f $SPLUNKDEPLOYMENTYAML