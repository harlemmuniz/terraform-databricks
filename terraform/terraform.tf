terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.45.0"
    }
  }
}

provider "databricks" {
  alias = "databricks"
  host  = var.host
}
