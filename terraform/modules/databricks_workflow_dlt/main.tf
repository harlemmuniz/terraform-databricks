resource "databricks_pipeline" "main" {
  provider = databricks.databricks

  name                  = var.name
  storage               = var.storage
  configuration         = var.configuration
  continuous            = var.continuous
  development           = var.ambiente == "prod" ? false : true
  photon                = var.photon
  catalog               = var.catalog
  target                = var.target
  edition               = var.edition
  channel               = var.channel
  allow_duplicate_names = false

  dynamic "library" {
    for_each = var.libraries
    content {
      dynamic "notebook" {
  
        for_each = lookup(library.value, "notebook", null) == null ? [] : [lookup(library.value, "notebook", null)]
        content {
          path = notebook.value.path
        }
      }
      dynamic "file" {
  
        for_each = lookup(library.value, "file", null) == null ? [] : [lookup(library.value, "file", null)]
        content {
          path = file.value.path
        }
      }
    }
  }

  dynamic "cluster" {
    for_each = var.clusters
    content {
      label               = lookup(cluster.value, "label", null)
      node_type_id        = lookup(cluster.value, "node_type_id", null)
      driver_node_type_id = lookup(cluster.value, "driver_node_type_id", null)
      custom_tags         = lookup(cluster.value, "custom_tags", null)
      num_workers         = lookup(cluster.value, "num_workers", null)

      dynamic "autoscale" {
  
        for_each = lookup(cluster.value, "autoscale", null) == null ? [] : [lookup(cluster.value, "autoscale", null)]
        content {
          mode        = lookup(autoscale.value, "mode", null)
          min_workers = lookup(autoscale.value, "min_workers", null)
          max_workers = lookup(autoscale.value, "max_workers", null)
        }
      }

      apply_policy_default_values  = lookup(cluster.value, "apply_policy_default_values", null)
      driver_instance_pool_id      = lookup(cluster.value, "driver_instance_pool_id", null)
      enable_local_disk_encryption = lookup(cluster.value, "enable_local_disk_encryption", null)
      instance_pool_id             = lookup(cluster.value, "instance_pool_id", null)
      policy_id                    = lookup(cluster.value, "policy_id", null)
      spark_conf                   = lookup(cluster.value, "spark_conf", null)
      spark_env_vars               = lookup(cluster.value, "spark_env_vars", null)
      ssh_public_keys              = lookup(cluster.value, "ssh_public_keys", null)
    }
  }

  dynamic "notification" {
    for_each = var.notifications[*]
    content {
      email_recipients = contains(notification.value.alerts, "on-flow-failure") == true || contains(notification.value.alerts, "on-update-fatal-failure") || contains(notification.value.alerts, "on-update-fatal-failure") ? lookup(notification.value, "email_recipients", null) != null ? distinct(concat(notification.value.email_recipients, var.destinatarios_alertas)) : var.destinatarios_alertas : lookup(notification.value, "email_recipients", null)
      alerts           = contains(notification.value.alerts, "on-flow-failure") == true || contains(notification.value.alerts, "on-update-fatal-failure") || contains(notification.value.alerts, "on-update-fatal-failure") ? distinct(concat(notification.value.alerts, ["on-flow-failure", "on-update-fatal-failure", "on-update-fatal-failure"])) : lookup(notification.value, "alerts", null)
    }
  }
}