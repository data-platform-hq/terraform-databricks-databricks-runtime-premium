locals {
  spark_conf_single_node = {
    "spark.master"                     = "local[*]"
    "spark.databricks.cluster.profile" = "singleNode"
  }
  conf_passthrought = {
    "spark.databricks.cluster.profile" : "serverless",
    "spark.databricks.repl.allowedLanguages" : "python,sql",
    "spark.databricks.passthrough.enabled" : "true",
    "spark.databricks.pyspark.enableProcessIsolation" : "true"
  }
}

resource "databricks_cluster" "cluster" {
  for_each = { for cluster in var.clusters : cluster.cluster_name => cluster }

  cluster_name  = each.value.cluster_name
  spark_version = each.value.spark_version
  spark_conf = merge(
    each.value.cluster_conf_passthrought ? local.conf_passthrought : {},
    each.value.single_node_enable == true ? local.spark_conf_single_node : {},
  each.value.spark_conf)
  spark_env_vars          = each.value.spark_env_vars
  data_security_mode      = each.value.cluster_conf_passthrought ? null : each.value.data_security_mode
  node_type_id            = each.value.node_type_id
  autotermination_minutes = each.value.autotermination_minutes
  single_user_name        = each.value.single_user_name
  custom_tags             = merge(each.value.single_node_enable ? { "ResourceClass" = "SingleNode" } : {}, each.value.custom_tags)

  azure_attributes {
    availability       = each.value.availability
    first_on_demand    = each.value.first_on_demand
    spot_bid_max_price = each.value.spot_bid_max_price
  }

  dynamic "autoscale" {
    for_each = each.value.single_node_enable ? [] : [1]
    content {
      min_workers = each.value.min_workers
      max_workers = each.value.max_workers
    }
  }

  dynamic "cluster_log_conf" {
    for_each = each.value.cluster_log_conf_destination != null ? [each.value.cluster_log_conf_destination] : []
    content {
      dbfs {
        destination = cluster_log_conf.value
      }
    }
  }

  dynamic "init_scripts" {
    for_each = each.value.init_scripts_workspace != null ? each.value.init_scripts_workspace : []
    content {
      workspace {
        destination = init_scripts.value
      }
    }
  }

  dynamic "init_scripts" {
    for_each = each.value.init_scripts_volumes != null ? each.value.init_scripts_volumes : []
    content {
      volumes {
        destination = init_scripts.value
      }
    }
  }

  dynamic "init_scripts" {
    for_each = each.value.init_scripts_dbfs != null ? each.value.init_scripts_dbfs : []
    content {
      dbfs {
        destination = init_scripts.value
      }
    }
  }

  dynamic "init_scripts" {
    for_each = each.value.init_scripts_abfss != null ? each.value.init_scripts_abfss : []
    content {
      abfss {
        destination = init_scripts.value
      }
    }
  }

  dynamic "library" {
    for_each = each.value.pypi_library_repository
    content {
      pypi {
        package = library.value
      }
    }
  }

  dynamic "library" {
    for_each = each.value.maven_library_repository
    content {
      maven {
        coordinates = library.value.coordinates
        exclusions  = library.value.exclusions
      }
    }
  }
}

resource "databricks_cluster_policy" "this" {
  for_each = {
    for param in var.custom_cluster_policies : (param.name) => param.definition
    if param.definition != null
  }

  name       = each.key
  definition = jsonencode(each.value)
}

resource "databricks_permissions" "this" {
  for_each = {
    for param in var.custom_cluster_policies : (param.name) => param.can_use
    if param.can_use != null
  }

  cluster_policy_id = databricks_cluster_policy.this[each.key].id

  dynamic "access_control" {
    for_each = each.value
    content {
      group_name       = access_control.value
      permission_level = "CAN_USE"
    }
  }
}

resource "databricks_cluster_policy" "overrides" {
  for_each = {
    for param in var.default_cluster_policies_override : (param.name) => param
    if param.definition != null
  }

  policy_family_id                   = each.value.family_id
  policy_family_definition_overrides = jsonencode(each.value.definition)
  name                               = each.key
}
