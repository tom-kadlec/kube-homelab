#!/usr/bin/env bash
# Full cluster bootstrap: Ansible → Terraform → Helmfile
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export KUBECONFIG="${KUBECONFIG:-$ROOT/kubeconfig/admin.conf}"
export ANSIBLE_CONFIG="${ANSIBLE_CONFIG:-$ROOT/ansible/ansible.cfg}"

echo "==> prepare"
make prepare

echo "==> cluster"
make cluster

echo "==> smoke"
make smoke

echo "==> platform (terraform + helmfile)"
make platform

echo "==> apps"
make apps

echo "Done. KUBECONFIG=$KUBECONFIG"