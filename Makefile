# kube-homelab — bootstrap orchestration
# Usage: make bootstrap | prepare | cluster | platform | apps

SHELL := /bin/bash
ROOT  := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

export KUBECONFIG ?= $(ROOT)/kubeconfig/admin.conf
# Force project ansible.cfg (do not inherit ANSIBLE_CONFIG from the shell).
override export ANSIBLE_CONFIG := $(ROOT)/ansible/ansible.cfg
export ANSIBLE_ROLES_PATH := $(ROOT)/ansible/roles

INVENTORY ?= $(ROOT)/inventory/hosts.yml
ANSIBLE   := ansible-playbook -i $(INVENTORY) --ask-become-pass
HELMFILE  := cd $(ROOT)/helmfile && helmfile
TF_DIR    := $(ROOT)/terraform

.PHONY: help prepare cluster reset smoke platform apps bootstrap \
	terraform-init terraform-plan terraform-apply helmfile-platform helmfile-apps

help:
	@echo "Targets:"
	@echo "  prepare     Ansible: OS prep + containerd + k8s packages"
	@echo "  cluster     Ansible: kubeadm init + CNI + join workers"
	@echo "  smoke       Ansible: basic cluster checks"
	@echo "  reset       Ansible: kubeadm reset (destructive)"
	@echo "  platform    Terraform apply + Helmfile platform releases"
	@echo "  apps        Helmfile application releases"
	@echo "  bootstrap   prepare + cluster + platform + apps"
	@echo ""
	@echo "Env: KUBECONFIG=$(KUBECONFIG)"

prepare:
	$(ANSIBLE) $(ROOT)/ansible/playbooks/01-prepare.yml
	$(ANSIBLE) $(ROOT)/ansible/playbooks/02-containerd.yml
	$(ANSIBLE) $(ROOT)/ansible/playbooks/03-kubernetes.yml

cluster:
	$(ANSIBLE) $(ROOT)/ansible/playbooks/04-init-master.yml
	$(ANSIBLE) $(ROOT)/ansible/playbooks/05-cni.yml
	$(ANSIBLE) $(ROOT)/ansible/playbooks/06-join-workers.yml

smoke:
	$(ANSIBLE) $(ROOT)/ansible/playbooks/07-smoke.yml

reset:
	$(ANSIBLE) $(ROOT)/ansible/playbooks/99-reset.yml

terraform-init:
	cd $(TF_DIR) && terraform init

terraform-plan: terraform-init
	cd $(TF_DIR) && terraform plan

terraform-apply: terraform-init
	cd $(TF_DIR) && terraform apply

helmfile-platform:
	$(HELMFILE) -e lab -l tier=platform apply

helmfile-apps:
	$(HELMFILE) -e lab -l tier=apps apply

platform: terraform-apply helmfile-platform

apps: helmfile-apps

bootstrap: prepare cluster smoke platform apps
	@echo "Bootstrap complete."