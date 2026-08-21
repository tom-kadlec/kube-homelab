module "namespaces" {
  source = "./modules/namespaces"

  namespaces = var.namespaces
}

module "quotas" {
  source = "./modules/quotas"

  namespaces = var.namespaces
  depends_on = [module.namespaces]
}

module "rbac" {
  source = "./modules/rbac"

  service_accounts = var.service_accounts
  role_bindings    = var.role_bindings
  depends_on       = [module.namespaces]
}

# Optional — enable when ready:
# module "network_policies" {
#   source     = "./modules/network_policies"
#   namespaces = var.namespaces
#   depends_on = [module.namespaces]
# }
