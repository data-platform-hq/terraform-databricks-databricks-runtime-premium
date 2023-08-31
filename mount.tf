resource "databricks_mount" "adls" {
  for_each = var.mount_enabled ? var.mountpoints : {}

  name       = each.key
  cluster_id = var.mount_cluster_name != null ? databricks_cluster.cluster[var.mount_cluster_name].id : null
  uri        = "abfss://${each.value["container_name"]}@${each.value["storage_account_name"]}.dfs.core.windows.net"
  extra_configs = var.mount_adls_passthrough ? {
    "fs.azure.account.auth.type" : "CustomAccessToken",
    "fs.azure.account.custom.token.provider.class" : "{{sparkconf/spark.databricks.passthrough.adls.gen2.tokenProviderClassName}}"
    } : {
    "fs.azure.account.auth.type" : "OAuth",
    "fs.azure.account.oauth.provider.type" : "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
    "fs.azure.account.oauth2.client.id" : var.mount_service_principal_client_id,
    "fs.azure.account.oauth2.client.secret" : databricks_secret.main["mount-sp-secret"].config_reference,
    "fs.azure.account.oauth2.client.endpoint" : "https://login.microsoftonline.com/${var.mount_service_principal_tenant_id}/oauth2/token",
    "fs.azure.createRemoteFileSystemDuringInitialization" : "false",
  }
}
