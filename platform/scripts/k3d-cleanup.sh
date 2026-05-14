#!/usr/bin/env bash
# Deletes the local k3d cluster created by k3d-setup.sh (Argo CD, ingress, workloads included).

set -euo pipefail

CLUSTER_NAME="${K3D_CLUSTER_NAME:-beautyplanner}"

if ! command -v k3d &>/dev/null; then
  echo "k3d is not installed; nothing to delete." >&2
  exit 1
fi

if k3d cluster get "${CLUSTER_NAME}" &>/dev/null; then
  echo "Deleting k3d cluster '${CLUSTER_NAME}'..."
  k3d cluster delete "${CLUSTER_NAME}"
  echo "Cluster '${CLUSTER_NAME}' removed."
else
  echo "No k3d cluster named '${CLUSTER_NAME}' (already absent)."
fi
