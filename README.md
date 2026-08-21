# kube-homelab

Idempotent bootstrap of a home Kubernetes cluster on Ubuntu VMs (Proxmox) using **kubeadm**.

## Layers

| Layer | Tool | Responsibility |
|-------|------|----------------|
| OS + cluster | Ansible | Ubuntu prep, containerd, kubeadm init/join, CNI |
| Identity & limits | Terraform | Namespaces, RBAC, ResourceQuota, LimitRange |
| Platform & apps | Helmfile | MetalLB, Ingress, cert-manager, storage, applications |

## Prerequisites

- 4× Ubuntu 22.04 VMs: `kube-master`, `kube-node1–3`
- SSH access (e.g. user `ubuntu` + key)
- Locally: `ansible`, `terraform`, `helm`, `helmfile`, `kubectl`

## Quick start

1. Edit `inventory/hosts.yml` (IP addresses).
2. Review `inventory/group_vars/all.yml` (K8s version, CIDR).
3. Copy `terraform/terraform.tfvars.example` → `terraform/terraform.tfvars`.
4. Run:

```bash
chmod +x scripts/*.sh
make bootstrap
# or: ./scripts/bootstrap.sh
```

Step by step: `make prepare` → `make cluster` → `make platform` → `make apps`.

Kubeconfig is fetched into `kubeconfig/admin.conf` (gitignored).

```bash
export KUBECONFIG=$PWD/kubeconfig/admin.conf
# or: cp .envrc.example .envrc && direnv allow
```

## Layout

```text
inventory/     Ansible inventory + group_vars
ansible/       playbooks and roles (OS → Ready nodes)
terraform/     namespaces, RBAC, quotas
helmfile/      platform + apps releases
docs/          architecture, bootstrap, recovery
scripts/       bootstrap.sh, wait-for-nodes.sh
```

## Documentation

- [Architecture](docs/architecture.md)
- [Bootstrap](docs/bootstrap.md)
- [Recovery / reset](docs/recovery.md)

## Notes

- CNI (Cilium) is installed via Ansible right after `kubeadm init` so workers can become Ready.
- MetalLB / Ingress / cert-manager / Longhorn are managed by Helmfile (`tier=platform`).
- Secrets belong in `secrets/` (out of git) or Ansible Vault / SOPS.
