resource "databricks_schema" "main" {
  provider = databricks.databricks

  name          = var.name
  storage_root  = var.storage_root
  catalog_name  = var.ambiente == "lab" ? "${trimsuffix(lower(var.catalog_name), "_lab")}_${var.ambiente}" : "${trimsuffix(lower(var.catalog_name), "_lab")}"
  owner         = var.owner != null ? (var.owner == "prod-user@org.com.br" ? "data_engineer" : var.owner) : "data_engineer"
  comment       = var.comment
  properties    = var.properties
  force_destroy = var.force_destroy
}
