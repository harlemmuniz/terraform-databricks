resource "databricks_sql_table" "main" {
  provider = databricks.databricks

  name                    = var.name
  catalog_name            = var.ambiente == "lab" ? "${trimsuffix(lower(var.catalog_name), "_lab")}_${var.ambiente}" : "${trimsuffix(lower(var.catalog_name), "_lab")}"
  schema_name             = var.schema_name
  table_type              = var.table_type
  comment                 = var.comment
  storage_location        = var.table_type != "MANAGED" ? var.storage_location : null
  data_source_format      = var.data_source_format
  view_definition         = var.view_definition
  cluster_id              = var.cluster_id
  warehouse_id            = var.warehouse_id
  cluster_keys            = var.cluster_keys
  storage_credential_name = var.storage_credential_name
  options                 = var.options
  properties              = var.properties
  partitions              = var.partitions
  # owner                   = var.owner != null ? (var.owner == "prod-user@org.com.br" ? "data_engineer" : var.owner) : "data_engineer"

  dynamic "column" {
    for_each = var.columns[*]
    content {
      name     = lookup(column.value, "name", null)
      type     = lookup(column.value, "type_text", null)
      comment  = lookup(column.value, "comment", null)
      nullable = lookup(column.value, "nullable", null)
    }
  }

}
