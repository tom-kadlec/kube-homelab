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
      default_cpu            = optional(string, "200m")
      default_memory         = optional(string, "256Mi")
      default_request_cpu    = optional(string, "50m")
      default_request_memory = optional(string, "64Mi")
    }), {})
  }))
}

resource "kubernetes_resource_quota" "this" {
  for_each = var.namespaces

  metadata {
    name      = "${each.key}-quota"
    namespace = each.key
  }

  spec {
    hard = {
      "requests.cpu"    = try(each.value.quota.requests_cpu, "2")
      "requests.memory" = try(each.value.quota.requests_memory, "4Gi")
      "limits.cpu"      = try(each.value.quota.limits_cpu, "4")
      "limits.memory"   = try(each.value.quota.limits_memory, "8Gi")
      "pods"            = try(each.value.quota.pods, "20")
    }
  }
}

resource "kubernetes_limit_range" "this" {
  for_each = {
    for k, v in var.namespaces : k => v
    if try(v.limit_range, null) != null
  }

  metadata {
    name      = "${each.key}-limits"
    namespace = each.key
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = try(each.value.limit_range.default_cpu, "200m")
        memory = try(each.value.limit_range.default_memory, "256Mi")
      }
      default_request = {
        cpu    = try(each.value.limit_range.default_request_cpu, "50m")
        memory = try(each.value.limit_range.default_request_memory, "64Mi")
      }
    }
  }
}
