resource "databricks_mount" "adls" {
  for_each = var.mountpoints

  name       = each.key
  cluster_id = var.mount_cluster_name != null ? databricks_cluster.cluster[var.mount_cluster_name].id : null
  uri        = "abfss://${each.value["container_name"]}@${each.value["storage_account_name"]}.dfs.core.windows.net"
  extra_configs = var.mount_adls_passthrough ? {
    "fs.azure.account.auth.type" : "CustomAccessToken",
    "fs.azure.account.custom.token.provider.class" : "{{sparkconf/spark.databricks.passthrough.adls.gen2.tokenProviderClassName}}"
    } : {
    "fs.azure.account.auth.type" : "OAuth",
    "fs.azure.account.oauth.provider.type" : "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
    "fs.azure.account.oauth2.client.id" : data.azurerm_key_vault_secret.sp_client_id.value,
    "fs.azure.account.oauth2.client.secret" : databricks_secret.main[data.azurerm_key_vault_secret.sp_key.name].config_reference,
    "fs.azure.account.oauth2.client.endpoint" : "https://login.microsoftonline.com/${data.azurerm_key_vault_secret.tenant_id.value}/oauth2/token",
    "fs.azure.createRemoteFileSystemDuringInitialization" : "false",
    "spark.databricks.sqldw.jdbc.service.principal.client.id" : data.azurerm_key_vault_secret.sp_client_id.value,
    "spark.databricks.sqldw.jdbc.service.principal.client.secret" : databricks_secret.main[data.azurerm_key_vault_secret.sp_key.name].config_reference
  }
}
