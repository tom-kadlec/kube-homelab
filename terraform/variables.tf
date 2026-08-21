variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig (admin.conf from Ansible)."
  default     = "../kubeconfig/admin.conf"
}

variable "namespaces" {
  type = map(object({
    labels = optional(map(string), {})
    quota = optional(object({
      requests_cpu    = optional(string, "2")
      requests_memory = optional(string, "4Gi")
      limits_cpu      = optional(string, "4")
      limits_memory   = optional(string, "8Gi")
      pods            = optional(string, "20")
    }), {})
    limit_range = optional(object({
      default_cpu      = optional(string, "200m")
      default_memory   = optional(string, "256Mi")
      default_request_cpu    = optional(string, "50m")
      default_request_memory = optional(string, "64Mi")
    }), {})
  }))
  description = "Namespaces to create with optional quotas and limit ranges."
  default     = {}
}

variable "service_accounts" {
  type = list(object({
    name      = string
    namespace = string
    labels    = optional(map(string), {})
  }))
  description = "ServiceAccounts to create."
  default     = []
}

variable "role_bindings" {
  type = list(object({
    name      = string
    namespace = string
    role_ref = object({
      api_group = optional(string, "rbac.authorization.k8s.io")
      kind      = string # Role or ClusterRole
      name      = string
    })
    subjects = list(object({
      kind      = string
      name      = string
      namespace = optional(string)
      api_group = optional(string)
    }))
  }))
  description = "RoleBindings (namespace-scoped)."
  default     = []
}
