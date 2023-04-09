resource "databricks_cluster" "cluster" {
  for_each = { for cluster in var.clusters : cluster.cluster_name => cluster }

  cluster_name            = each.value.cluster_name
  spark_version           = each.value.spark_version
  spark_conf              = each.value.spark_conf
  spark_env_vars          = each.value.spark_env_vars
  data_security_mode      = each.value.data_security_mode
  node_type_id            = each.value.node_type_id
  autotermination_minutes = each.value.autotermination_minutes

  autoscale {
    min_workers = each.value.min_workers
    max_workers = each.value.max_workers
  }

  azure_attributes {
    availability       = each.value.availability
    first_on_demand    = each.value.first_on_demand
    spot_bid_max_price = each.value.spot_bid_max_price
  }

  dynamic "cluster_log_conf" {
    for_each = each.value.cluster_log_conf_destination != null ? [each.value.cluster_log_conf_destination] : []
    content {
      dbfs {
        destination = cluster_log_conf.value
      }
    }
  }

  lifecycle {
    ignore_changes = [
      state
    ]
  }
}
