locals {
  ip_rules = var.ip_rules == null ? null : values(var.ip_rules)
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

resource "databricks_sql_endpoint" "this" {
  for_each = var.sql_endpoint

  name                      = "${each.key}-${var.project}-${var.env}"
  cluster_size              = lookup(each.value, "cluster_size", var.default_values_sql_endpoint["cluster_size"])
  min_num_clusters          = lookup(each.value, "min_num_clusters", var.default_values_sql_endpoint["min_num_clusters"])
  max_num_clusters          = lookup(each.value, "max_num_clusters", var.default_values_sql_endpoint["max_num_clusters"])
  auto_stop_mins            = lookup(each.value, "auto_stop_mins", var.default_values_sql_endpoint["auto_stop_mins"])
  enable_photon             = lookup(each.value, "enable_photon", var.default_values_sql_endpoint["enable_photon"])
  enable_serverless_compute = lookup(each.value, "enable_serverless_compute", var.default_values_sql_endpoint["enable_serverless_compute"])
}
