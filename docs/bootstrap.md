# Bootstrap

## 1. Inventory

Edit IPs and user in `inventory/hosts.yml`:

```yaml
kube-master: { ansible_host: 192.168.x.10 }
kube-node1:  { ansible_host: 192.168.x.11 }
# …
```

Verify SSH:

```bash
ansible -i inventory/hosts.yml all -m ping
```

## 2. Variables

- `inventory/group_vars/all.yml` — Kubernetes version, pod CIDR, timezone
- `terraform/terraform.tfvars` — namespaces, quotas (from the example)
- `helmfile/values/*` — MetalLB IP pool, Ingress domains, …

## 3. Run

Full stack:

```bash
make bootstrap
```

Step by step:

```bash
make prepare    # OS + containerd + kubelet/kubeadm/kubectl
make cluster    # init + Cilium + join
make smoke      # nodes Ready
make platform   # terraform + helmfile platform
make apps       # helmfile apps
```

## 4. kubectl

```bash
export KUBECONFIG=$PWD/kubeconfig/admin.conf
kubectl get nodes
kubectl get pods -A
```

## Dependency order

1. Without CNI, workers stay NotReady → CNI is installed in Ansible (`05-cni.yml`).
2. Terraform needs a working API (`KUBECONFIG`).
3. Helmfile platform needs Ready nodes; MetalLB needs free IPs from your LAN.
