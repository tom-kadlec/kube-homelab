variable "service_accounts" {
  type = list(object({
    name      = string
    namespace = string
    labels    = optional(map(string), {})
  }))
  default = []
}

variable "role_bindings" {
  type = list(object({
    name      = string
    namespace = string
    role_ref = object({
      api_group = optional(string, "rbac.authorization.k8s.io")
      kind      = string
      name      = string
    })
    subjects = list(object({
      kind      = string
      name      = string
      namespace = optional(string)
      api_group = optional(string)
    }))
  }))
  default = []
}

resource "kubernetes_service_account" "this" {
  for_each = {
    for sa in var.service_accounts : "${sa.namespace}/${sa.name}" => sa
  }

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
    labels    = each.value.labels
  }
}

resource "kubernetes_role_binding" "this" {
  for_each = {
    for rb in var.role_bindings : "${rb.namespace}/${rb.name}" => rb
  }

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
  }

  role_ref {
    api_group = try(each.value.role_ref.api_group, "rbac.authorization.k8s.io")
    kind      = each.value.role_ref.kind
    name      = each.value.role_ref.name
  }

  dynamic "subject" {
    for_each = each.value.subjects
    content {
      kind      = subject.value.kind
      name      = subject.value.name
      namespace = try(subject.value.namespace, null)
      api_group = try(subject.value.api_group, null)
    }
  }

  depends_on = [kubernetes_service_account.this]
}
