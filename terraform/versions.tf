terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33"
    }
  }

  # Local state for lab; switch to remote later if needed.
  backend "local" {
    path = "terraform.tfstate"
  }
}
