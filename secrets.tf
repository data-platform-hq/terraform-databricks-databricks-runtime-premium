locals {
  sp_secrets = {
    (var.sp_client_id_secret_name) = { value = data.azurerm_key_vault_secret.sp_client_id.value }
    (var.sp_key_secret_name)       = { value = data.azurerm_key_vault_secret.sp_key.value }
  }

  secrets_objects_list = flatten([for param in var.secret_scope : [
    for secret in param.secrets : {
      scope_name = param.scope_name, key = secret.key, string_value = secret.string_value
    }] if param.secrets != null
  ])
}

# Secret Scope with SP secrets for mounting Azure Data Lake Storage
resource "databricks_secret_scope" "main" {
  name                     = "main"
  initial_manage_principal = null
}

resource "databricks_secret" "main" {
  for_each = local.sp_secrets

  key          = each.key
  string_value = each.value["value"]
  scope        = databricks_secret_scope.main.id
}

# Custom additional Databricks Secret Scope
resource "databricks_secret_scope" "this" {
  for_each = {
    for param in var.secret_scope : (param.scope_name) => param
    if param.scope_name != null
  }

  name                     = each.key
  initial_manage_principal = null
}

resource "databricks_secret" "this" {
  for_each = { for entry in local.secrets_objects_list : "${entry.scope_name}.${entry.key}" => entry }

  key          = each.value.key
  string_value = each.value.string_value
  scope        = databricks_secret_scope.this[each.value.scope_name].id
}

# At the nearest future, Azure will allow acquiring AAD tokens by service principals,
# thus providing an ability to create Azure backed Key Vault with Terraform
# https://github.com/databricks/terraform-provider-databricks/pull/1965

## Azure Key Vault-backed Scope
#resource "azurerm_key_vault_access_policy" "databricks" {
#  count = var.key_vault_secret_scope.key_vault_id != null ? 1 : 0

#  key_vault_id = var.key_vault_secret_scope.key_vault_id
#  object_id    = "9b38785a-6e08-4087-a0c4-20634343f21f" # Global 'AzureDatabricks' SP object id
#  tenant_id    = data.azurerm_key_vault_secret.tenant_id.value
#
#  secret_permissions = [
#    "Get",
#    "List",
#  ]
#}
#
#resource "databricks_secret_scope" "external" {
#  count = var.key_vault_secret_scope.key_vault_id != null ? 1 : 0
#
#  name = "external"
#  keyvault_metadata {
#    resource_id = var.key_vault_secret_scope.key_vault_id
#    dns_name    = var.key_vault_secret_scope.dns_name
#  }
#  depends_on = [azurerm_key_vault_access_policy.databricks]
#}
