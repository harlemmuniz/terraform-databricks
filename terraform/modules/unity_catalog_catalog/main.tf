resource "databricks_catalog" "main" {
  provider = databricks.databricks

  name            = var.ambiente == "lab" ? "${trimsuffix(lower(var.name), "_lab")}_${var.ambiente}" : "${trimsuffix(lower(var.name), "_lab")}"
  storage_root    = var.storage_root
  comment         = var.comment
  owner           = var.owner != null ? (var.owner == "prod-user@org.com.br" ? "data_engineer" : var.owner) : "data_engineer"
  provider_name   = var.provider_name
  share_name      = var.share_name
  connection_name = var.connection_name
  isolation_mode  = var.isolation_mode
  properties      = var.properties
  force_destroy   = var.force_destroy
}
