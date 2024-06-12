resource "databricks_notebook" "main" {
  provider = databricks.databricks

  source = var.notebook_source
  path   = var.notebook_path
}
