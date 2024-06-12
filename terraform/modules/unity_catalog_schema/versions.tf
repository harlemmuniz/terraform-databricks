terraform {
  required_providers {

    databricks = {
      source                = "databricks/databricks"
      version               = "1.45.0"
      configuration_aliases = [databricks.databricks]
    }

  }
}