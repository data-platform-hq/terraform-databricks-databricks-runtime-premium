resource "databricks_git_credential" "this" {
  for_each = { for i in var.repository_credential : i.git_username => i if i.personal_access_token != null }

  git_username          = each.value.git_username
  git_provider          = each.value.git_provider
  personal_access_token = sensitive(each.value.personal_access_token)
  force                 = each.value.force
}

resource "databricks_repo" "this" {
  for_each = { for i in var.repository_url : i.url => i if i.url != null }

  branch = each.value.branch
  url    = each.value.url
  path   = each.value.path
}
