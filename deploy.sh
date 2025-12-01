#!/usr/bin/env bash
set -euo pipefail

# Config
NAME="kubernetes-demo-api"
USERNAME="peterdiyo"
SERVICE="devops-kubernetes-api-service"
IMAGE="$USERNAME/$NAME:latest"

echo "Building Docker image: $IMAGE"
docker build -t "$IMAGE" .

echo "Pushing Docker image to Docker Hub: $IMAGE"
if ! docker info --format '{{json .}}' >/dev/null 2>&1; then
	echo "Docker is not available or not running. Please ensure Docker is running and try again."
	exit 1
fi
if ! docker system info --format '{{json .}}' | grep -q 'AuthConfig'; then
	# Best effort: check if user is logged in; 'docker login' required to push
	echo "Make sure you're logged into Docker Hub (docker login) with account that can push to $USERNAME."
fi
docker push "$IMAGE"

echo "Applying Kubernetes manifests..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

echo "Getting pods ..."
kubectl get pods 

echo "Getting services ..."
kubectl get services

echo "Fetching the main service: $SERVICE"
kubectl get services "$SERVICE" || kubectl get services