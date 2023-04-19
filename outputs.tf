output "sql_endpoint_jdbc_url" {
  value       = [for n in databricks_sql_endpoint.this : n.jdbc_url]
  description = "JDBC connection string of SQL Endpoint"
}

output "sql_endpoint_data_source_id" {
  value       = [for n in databricks_sql_endpoint.this : n.data_source_id]
  description = "ID of the data source for this endpoint"
}

output "metastore_id" {
  value       = var.create_metastore ? databricks_metastore.this[0].id : ""
  description = "Unity Catalog Metastore Id"
}

output "token" {
  value       = databricks_token.pat.token_value
  description = "Databricks Personal Authorization Token"
  sensitive   = true
}

output "clusters" {
  value = [for param in var.clusters : {
    name = param.cluster_name
    id   = databricks_cluster.cluster[param.cluster_name].id
  } if length(var.clusters) != 0]
  description = "Provides name and unique identifier for the clusters"
}
