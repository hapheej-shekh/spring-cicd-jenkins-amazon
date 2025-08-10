#!/bin/bash
set -e

# Replace with your actual cluster name and region
CLUSTER_NAME="iam-eks-cluster"
AWS_REGION="ap-south-1"
PROFILE_USER="eks-admin"

aws eks --region $AWS_REGION update-kubeconfig --name $CLUSTER_NAME --profile $PROFILE_USER --no-cli-pager
