#!/usr/bin/env bash
# Local multi-node cluster (k3d): 1 server + 2 agents, NGINX Ingress, cert-manager PKI, Argo CD.
# Requires: Docker, k3d (v5+), kubectl. Optional: override cluster name with K3D_CLUSTER_NAME.

set -euo pipefail

CLUSTER_NAME="${K3D_CLUSTER_NAME:-beautyplanner}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_ROOT}"

INGRESS_NGINX_MANIFEST="https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.3/deploy/static/provider/baremetal/deploy.yaml"
CERT_MANAGER_MANIFEST="https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml"
ARGOCD_MANIFEST="https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"

require_cmd() {
  if ! command -v "$1" &>/dev/null; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_cmd docker
require_cmd k3d
require_cmd kubectl

if docker info &>/dev/null; then
  :
else
  echo "Docker daemon is not reachable. Start Docker and retry." >&2
  exit 1
fi

if k3d cluster get "${CLUSTER_NAME}" &>/dev/null; then
  echo "k3d cluster '${CLUSTER_NAME}' already exists. Delete it first:" >&2
  echo "  K3D_CLUSTER_NAME=${CLUSTER_NAME} ./platform/scripts/k3d-cleanup.sh" >&2
  exit 1
fi

echo "Creating k3d cluster '${CLUSTER_NAME}' (1 server, 2 agents, Traefik disabled)..."
k3d cluster create "${CLUSTER_NAME}" \
  --servers 1 \
  --agents 2 \
  --kubeconfig-update-default \
  --kubeconfig-switch-context \
  --k3s-arg '--disable=traefik@server:0'

echo "Installing NGINX Ingress Controller (${INGRESS_NGINX_MANIFEST})..."
kubectl apply -f "${INGRESS_NGINX_MANIFEST}"

echo "Waiting for NGINX Ingress controller rollout..."
kubectl rollout status deployment/ingress-nginx-controller -n ingress-nginx --timeout=300s

echo "Installing cert-manager..."
kubectl apply -f "${CERT_MANAGER_MANIFEST}"

echo "Waiting for cert-manager pods..."
kubectl wait --for=condition=Ready pods --all -n cert-manager --timeout=300s

echo "Applying cert-manager PKI manifests (repo)..."
kubectl apply -f "${REPO_ROOT}/platform/k8s/cert-manager/"

echo "Waiting for wildcard certificate to be ready..."
kubectl wait --for=condition=Ready "certificate/localhost-wildcard-cert" -n cert-manager --timeout=120s

echo "Patching NGINX Ingress default TLS certificate (fallback)..."
kubectl patch deployment ingress-nginx-controller -n ingress-nginx --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--default-ssl-certificate=cert-manager/localhost-tls-secret"}]'

kubectl rollout status deployment/ingress-nginx-controller -n ingress-nginx --timeout=300s

echo "Installing Argo CD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply --server-side --force-conflicts -n argocd -f "${ARGOCD_MANIFEST}"

echo "Waiting for Argo CD pods..."
sleep 10
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

echo ""
echo "Bootstrap finished for cluster '${CLUSTER_NAME}'."
echo "---------------------------------------------------"
echo "Argo CD initial admin password:"
echo -n "  "
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""
echo "---------------------------------------------------"
echo "From the host (new terminal):"
echo "  kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8443:443"
echo "  ./platform/scripts/extract-ca.sh"
echo "Then open (after trusting rootCA.crt):"
echo "  https://argocd.localhost:8443"
echo "  https://planner.localhost:8443/command"
echo "  https://planner.localhost:8443/query"
echo "---------------------------------------------------"
echo "Nodes:"
kubectl get nodes -o wide
