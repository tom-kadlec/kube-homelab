# Architecture

## Topology

```text
Proxmox
├── kube-master   (control plane: apiserver, etcd, scheduler, controller-manager)
├── kube-node1    (worker)
├── kube-node2    (worker)
└── kube-node3    (worker)
```

Simple lab: **1 master + 3 workers**. HA control plane can come later.

## Bootstrap pipeline

```text
Ansible prepare
  → containerd + kube packages
  → kubeadm init (master)
  → CNI (Cilium)
  → kubeadm join (workers)
Terraform
  → namespaces, RBAC, quotas
Helmfile
  → platform (MetalLB, Ingress, cert-manager, storage)
  → apps
```

## Tool boundaries

| Owns | Tool |
|------|------|
| sysctl, swap, packages, kubeadm, join, CNI | Ansible |
| Namespace, ServiceAccount, Role(Binding), Quota | Terraform |
| Platform and application Helm charts | Helmfile |

## Networking (default lab)

- Pod CIDR: `10.244.0.0/16` (see `inventory/group_vars/all.yml`) — must match CNI
- Service CIDR: kubeadm default (`10.96.0.0/12`) unless changed
- MetalLB pool: set in `helmfile/values/metallb/` (or environment values) for your LAN

## Where state lives

| State | Location |
|-------|----------|
| Cluster (etcd) | on the master VM |
| Terraform state | `terraform/terraform.tfstate` (local; remote later if needed) |
| Helm releases | in-cluster (Helm secrets) |
| kubeconfig | `kubeconfig/admin.conf` (local, not in git) |
