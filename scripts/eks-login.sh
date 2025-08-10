#!/bin/bash

# Replace with your actual cluster name and region
CLUSTER_NAME="iam-eks-cluster"
AWS_REGION="ap-south-1"

echo "[INFO] Getting cluster credentials..."
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
