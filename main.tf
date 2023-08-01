locals {
  ip_rules = var.ip_rules == null ? null : values(var.ip_rules)
  suffix   = length(var.suffix) == 0 ? "" : "-${var.suffix}"
}

data "azurerm_key_vault_secret" "sp_client_id" {
  count = var.mountpoints == {} ? 0 : 1

  name         = var.sp_client_id_secret_name
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "sp_key" {
  count = var.mountpoints == {} ? 0 : 1

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

resource "databricks_token" "pat" {
  comment          = "Terraform Provisioning"
  lifetime_seconds = var.pat_token_lifetime_seconds
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
  cluster_size              = each.value.cluster_size
  min_num_clusters          = each.value.min_num_clusters
  max_num_clusters          = each.value.max_num_clusters
  auto_stop_mins            = each.value.auto_stop_mins
  enable_photon             = each.value.enable_photon
  enable_serverless_compute = each.value.enable_serverless_compute
  spot_instance_policy      = each.value.spot_instance_policy
  warehouse_type            = each.value.warehouse_type

  lifecycle {
    ignore_changes = [state, num_clusters]
  }
  depends_on = [databricks_sql_global_config.this]
}
