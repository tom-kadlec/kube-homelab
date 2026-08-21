# Placeholder module — add NetworkPolicy resources when ready.
#
# variable "namespaces" { … }
# resource "kubernetes_network_policy" "default_deny" { … }

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
