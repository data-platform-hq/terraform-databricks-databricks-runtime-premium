output "sql_endpoint_jdbc_url" {
  value       = [for n in databricks_sql_endpoint.this : n.jdbc_url]
  description = "JDBC connection string of SQL Endpoint"
}

output "sql_endpoint_data_source_id" {
  value       = [for n in databricks_sql_endpoint.this : n.data_source_id]
  description = "ID of the data source for this endpoint"
}

output "token" {
  value       = databricks_token.pat.token_value
  description = "Databricks Personal Authorization Token"
  sensitive   = true
}
