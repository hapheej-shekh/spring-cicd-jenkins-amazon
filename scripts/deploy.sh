#!/bin/bash

echo "[INFO] Deploying to EKS..."

# kubectl apply -f k8s/deployment.yaml
# kubectl apply -f k8s/service.yaml

kubectl apply -f k8s/

