variable "namespaces" {
  type = map(object({
    labels = optional(map(string), {})
  }))
}

resource "kubernetes_namespace" "this" {
  for_each = var.namespaces

  metadata {
    name   = each.key
    labels = each.value.labels
  }
}

output "names" {
  value = keys(kubernetes_namespace.this)
}
