# Recovery

Four common recovery scenarios.

## A) Rebuild Kubernetes on existing VMs

```bash
make reset      # kubeadm reset + cleanup (destructive)
make prepare
make cluster
make smoke
make platform
make apps
```

Terraform state can remain; after a new cluster, `terraform apply` usually recreates objects (or run `terraform init` + apply against an empty API).

## B) Full VM rebuild (Proxmox)

1. Recreate / restore Ubuntu VM snapshots.
2. Verify IPs in `inventory/hosts.yml`.
3. `make bootstrap`.

## C) RBAC / quotas only

```bash
export KUBECONFIG=$PWD/kubeconfig/admin.conf
make terraform-apply
```

## D) Platform or apps only

```bash
make helmfile-platform
make apps
```

## Notes

- Do not commit join tokens; Ansible generates them in `04-init-master` / `06-join-workers`.
- After `kubeadm reset`, delete the old `kubeconfig/admin.conf` and let Ansible fetch it again from the master.
- Longhorn / PV data on worker disks may survive a cluster reset — for a clean lab, wipe data manually or restore the VM disk.
