locals {
  ip_rules = var.ip_rules == null ? null : values(var.ip_rules)
  suffix   = length(var.suffix) == 0 ? "" : "-${var.suffix}"
}

data "azurerm_key_vault_secret" "sp_client_id" {
  name         = var.sp_client_id_secret_name
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "sp_key" {
  name         = var.sp_key_secret_name
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "tenant_id" {
  name         = var.tenant_id_secret_name
  key_vault_id = var.key_vault_id
}

resource "databricks_workspace_conf" "this" {
  count = local.ip_rules == null ? 0 : 1

  custom_config = {
    "enableIpAccessLists" : true
  }
}

resource "databricks_ip_access_list" "this" {
  count = local.ip_rules == null ? 0 : 1

  label        = "allow_in"
  list_type    = "ALLOW"
  ip_addresses = local.ip_rules

  depends_on = [databricks_workspace_conf.this]
}

# SQL Endpoint
resource "databricks_sql_global_config" "this" {
  count = anytrue(var.sql_endpoint[*].enable_serverless_compute) ? 1 : 0

  enable_serverless_compute = true
}

resource "databricks_sql_endpoint" "this" {
  for_each = { for endpoint in var.sql_endpoint : (endpoint.name) => endpoint }

  name                      = "${each.key}${local.suffix}"
  cluster_size              = coalesce(each.value.cluster_size, "2X-Small")
  min_num_clusters          = coalesce(each.value.min_num_clusters, 0)
  max_num_clusters          = coalesce(each.value.max_num_clusters, 1)
  auto_stop_mins            = coalesce(each.value.auto_stop_mins, "30")
  enable_photon             = coalesce(each.value.enable_photon, false)
  enable_serverless_compute = coalesce(each.value.enable_serverless_compute, false)
  spot_instance_policy      = coalesce(each.value.spot_instance_policy, "COST_OPTIMIZED")
  warehouse_type            = coalesce(each.value.warehouse_type, "PRO")

  lifecycle {
    ignore_changes = [state, num_clusters]
  }
  depends_on = [databricks_sql_global_config.this]
}
