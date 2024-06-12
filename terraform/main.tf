locals {
  job_files = fileset("../workflows/jobs/", "*.json")
  job_data = [for f in local.job_files : jsondecode(file("../workflows/jobs/${f}"))]

  notebooks_files = toset([for f in fileset("../notebooks/**", "*.*") : f if length(regexall("/Users/", f)) <= 0])

  dlt_files = fileset("../workflows/dlt/", "*.json")
  dlt_data  = [for f in local.dlt_files : jsondecode(file("../workflows/dlt/${f}"))]

  catalog_files = fileset("../unity_catalog/catalogs/**", "*.json")
  catalog_data  = [for f in local.catalog_files : jsondecode("${file(replace("../unity_catalog/catalogs/${f}", "catalogs/..", "catalogs/"))}")]

  schema_files = fileset("../unity_catalog/schemas/**", "*.json")
  schema_data  = [for f in local.schema_files : jsondecode("${file(replace("../unity_catalog/schemas/${f}", "schemas/..", "schemas/"))}")]

  table_files = fileset("../unity_catalog/tables/**", "*.json")
  table_data  = [for f in local.table_files : jsondecode("${file(replace("../unity_catalog/tables/${f}", "tables/..", "tables/"))}")]
}

module "databricks_notebook_module" {
  providers = {
    databricks.databricks = databricks.databricks
  }

  source          = "./modules/databricks_notebook"
  for_each        = local.notebooks_files
  notebook_source = "../notebooks/${trimprefix("${each.value}", "../")}"
  notebook_path   = trimsuffix(trimsuffix(trimprefix("${each.value}", ".."), ".py"), ".sql")

  depends_on = [module.databricks_uc_catalog_module, module.databricks_uc_schema_module, module.databricks_uc_table_module]
}

module "databricks_workflow_job_module" {
  providers = {
    databricks.databricks = databricks.databricks
  }
  source = "./modules/databricks_workflow_job"

  ambiente                        = var.ambiente
  destinatarios_alertas           = var.destinatarios_alertas
  destinatarios_alertas_streaming = var.destinatarios_alertas_streaming
  for_each                        = { for f in local.job_data : f.name => f }
  name                            = lookup(each.value, "name", null)
  description                     = lookup(each.value, "description", null)
  min_retry_interval_millis       = lookup(each.value, "min_retry_interval_millis", null)
  control_run_state               = lookup(each.value, "continuous", null) != null ? true : false
  tags                            = lookup(each.value, "tags", null)
  retry_on_timeout                = lookup(each.value, "retry_on_timeout", null)
  max_retries                     = lookup(each.value, "max_retries", null)
  timeout_seconds                 = lookup(each.value, "timeout_seconds", null)
  max_concurrent_runs             = lookup(each.value, "max_concurrent_runs", null)
  health                          = lookup(each.value, "health", null)
  libraries                       = lookup(each.value, "libraries", null)
  job_clusters                    = lookup(each.value, "job_clusters", null)
  git_source                      = lookup(each.value, "git_source", null)
  continuous                      = lookup(each.value, "continuous", null)
  schedule                        = lookup(each.value, "schedule", null)
  trigger                         = lookup(each.value, "trigger", null)
  tasks                           = lookup(each.value, "tasks", null)
  run_as                          = lookup(each.value, "run_as", null)
  queue                           = lookup(each.value, "queue", null)
  notification_settings           = lookup(each.value, "notification_settings", {"notification_settings": { "no_alert_for_skipped_runs": true, "no_alert_for_canceled_runs": true }})
  email_notifications             = lookup(each.value, "email_notifications", null)
  webhook_notifications           = lookup(each.value, "webhook_notifications", {})
  parameters                      = lookup(each.value, "parameters", null)

  webhook_destinations = lookup(each.value, "webhook_notifications", null) != null ? lookup(each.value.webhook_notifications, "on_failure", null) != null ? concat(
    var.webhook_destinations,
    [for notification in each.value.webhook_notifications.on_failure : notification.id]
  ) : var.webhook_destinations : var.webhook_destinations

  depends_on = [module.databricks_notebook_module]
}

module "databricks_workflow_dlt_module" {
  providers = {
    databricks.databricks = databricks.databricks
  }

  source                = "./modules/databricks_workflow_dlt"
  for_each              = { for f in local.dlt_data : f.name => f }
  ambiente              = var.ambiente
  destinatarios_alertas = var.destinatarios_alertas
  pipeline_type         = lookup(each.value, "pipeline_type", null)
  clusters              = lookup(each.value, "clusters", [])
  development           = lookup(each.value, "development", null)
  continuous            = lookup(each.value, "continuous", null)
  channel               = lookup(each.value, "channel", null)
  photon                = lookup(each.value, "photon", null)
  libraries             = lookup(each.value, "libraries", [])
  name                  = lookup(each.value, "name", null)
  edition               = lookup(each.value, "edition", null)
  storage               = lookup(each.value, "storage", null)
  configuration         = lookup(each.value, "configuration", null)
  target                = lookup(each.value, "target", null)
  notifications         = lookup(each.value, "notifications", [{ "email_recipients" : [], "alerts" : ["on-update-failure", "on-update-fatal-failure", "on-flow-failure"] }])
  catalog               = lookup(each.value, "catalog", null)
  depends_on            = [module.databricks_notebook_module]
}

module "databricks_uc_catalog_module" {
  # Child module do recurso Terraform de Catalog de Unity Catalog
  providers = {
    databricks.databricks = databricks.databricks
  }

  source          = "./modules/unity_catalog_catalog"
  for_each        = { for f in local.catalog_data : f.name => f }
  name            = lookup(each.value, "name", null)
  ambiente        = var.ambiente
  storage_root    = lookup(each.value, "storage_root", null)
  provider_name   = lookup(each.value, "provider_name", null)
  share_name      = lookup(each.value, "share_name", null)
  connection_name = lookup(each.value, "connection_name", null)
  owner           = lookup(each.value, "owner", "data_engineer")
  isolation_mode  = lookup(each.value, "isolation_mode", null)
  comment         = lookup(each.value, "comment", null)
  properties      = lookup(each.value, "properties", null)
  options         = lookup(each.value, "options", null)
  force_destroy   = lookup(each.value, "force_destroy", null)

  # depends_on = [module.databricks_notebook_module]
}

module "databricks_uc_schema_module" {
  # Child module do recurso Terraform de Schema de Unity Catalog
  providers = {
    databricks.databricks = databricks.databricks
  }

  source        = "./modules/unity_catalog_schema"
  for_each      = { for f in local.schema_data : f.name => f }
  name          = lookup(each.value, "name", null)
  ambiente      = var.ambiente
  storage_root  = lookup(each.value, "storage_root", null)
  owner         = lookup(each.value, "owner", "data_engineer")
  comment       = lookup(each.value, "comment", null)
  properties    = lookup(each.value, "properties", null)
  catalog_name  = lookup(each.value, "catalog_name", null)
  force_destroy = lookup(each.value, "force_destroy", null)

  depends_on = [module.databricks_uc_catalog_module]
}

module "databricks_uc_table_module" {
  # Child module do recurso Terraform de Table/View de Unity Catalog
  providers = {
    databricks.databricks = databricks.databricks
  }

  source                  = "./modules/unity_catalog_table"
  for_each                = { for f in local.table_data : f.name => f }
  name                    = lookup(each.value, "name", null)
  ambiente                = var.ambiente
  catalog_name            = lookup(each.value, "catalog_name", null)
  # owner                   = lookup(each.value, "owner", "data_engineer")
  columns                 = lookup(each.value, "columns", null)
  comment                 = lookup(each.value, "comment", null)
  properties              = lookup(each.value, "properties", null)
  schema_name             = lookup(each.value, "schema_name", null)
  storage_location        = lookup(each.value, "storage_location", null)
  view_definition         = lookup(each.value, "view_definition", null)
  data_source_format      = lookup(each.value, "data_source_format", null)
  storage_credential_name = lookup(each.value, "storage_credential_name", null)
  cluster_id              = lookup(each.value, "cluster_id", null)
  table_type              = lookup(each.value, "table_type", null)
  warehouse_id            = lookup(each.value, "warehouse_id", null)
  cluster_keys            = lookup(each.value, "cluster_keys", null)
  options                 = lookup(each.value, "options", null)
  partitions              = lookup(each.value, "partitions", null)

  depends_on = [module.databricks_uc_catalog_module, module.databricks_uc_schema_module]
}
