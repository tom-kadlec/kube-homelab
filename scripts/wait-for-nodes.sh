#!/usr/bin/env bash
# Wait until all nodes are Ready.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export KUBECONFIG="${KUBECONFIG:-$ROOT/kubeconfig/admin.conf}"

TIMEOUT="${1:-300}"
INTERVAL=5
elapsed=0

echo "Waiting for nodes Ready (timeout=${TIMEOUT}s)…"
while true; do
  if kubectl get nodes --no-headers 2>/dev/null | awk '{print $2}' | grep -qv '^Ready$'; then
    :
  else
    count="$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')"
    if [[ "$count" -gt 0 ]]; then
      kubectl get nodes
      echo "All $count nodes Ready."
      exit 0
    fi
  fi
  if [[ "$elapsed" -ge "$TIMEOUT" ]]; then
    echo "Timeout waiting for nodes." >&2
    kubectl get nodes || true
    exit 1
  fi
  sleep "$INTERVAL"
  elapsed=$((elapsed + INTERVAL))
done