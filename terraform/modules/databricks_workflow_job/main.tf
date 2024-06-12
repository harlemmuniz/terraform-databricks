resource "databricks_job" "main" {
  provider = databricks.databricks

  name                      = var.name
  description               = var.description
  min_retry_interval_millis = var.min_retry_interval_millis
  control_run_state         = var.continuous != null ? true : false
  tags                      = var.tags
  retry_on_timeout          = var.retry_on_timeout
  max_retries               = var.max_retries
  timeout_seconds           = var.timeout_seconds
  max_concurrent_runs       = var.max_concurrent_runs

  dynamic "parameter" {
    for_each = var.parameters[*]
    content {
      name    = lookup(parameter.value, "name", null)
      default = lookup(parameter.value, "default", null)
    }
  }

  dynamic "health" {
    for_each = var.health[*]
    content {
      rules {
        metric = lookup(var.health.rules[0], "metric", null)
        op     = lookup(var.health.rules[0], "op", null)
        value  = lookup(var.health.rules[0], "value", null)
      }
    }
  }

  dynamic "library" {
    for_each = var.libraries[*]
    content {
      jar = lookup(var.libraries, "jar", null)
      dynamic "pypi" {
  
        for_each = lookup(var.libraries, "pypi", null)[*]
        content {
          package = lookup(var.libraries.pypi, "package", null)
          repo    = lookup(var.libraries.pypi, "repo", null)
        }
      }
      dynamic "cran" {
  
        for_each = lookup(var.libraries, "cran", null)[*]
        content {
          package = lookup(var.libraries.cran, "package", null)
          repo    = lookup(var.libraries.cran, "repo", null)
        }
      }
      dynamic "maven" {
  
        for_each = lookup(var.libraries, "maven", null)[*]
        content {
          coordinates = lookup(var.libraries.maven, "coordinates", null)
          exclusions  = lookup(var.libraries.maven, "exclusions", null)
          repo        = lookup(var.libraries.maven, "repo", null)
        }
      }
    }
  }

  dynamic "job_cluster" {
    for_each = var.job_clusters[*]
    content {
      job_cluster_key = lookup(var.job_clusters[job_cluster.key], "job_cluster_key", null)
      dynamic "new_cluster" {
  
        for_each = lookup(var.job_clusters[job_cluster.key], "new_cluster", null)[*]
        content {
          cluster_name  = lookup(var.job_clusters[job_cluster.key].new_cluster, "cluster_name", null)
          spark_version = lookup(var.job_clusters[job_cluster.key].new_cluster, "spark_version", null)
          spark_conf    = lookup(var.job_clusters[job_cluster.key].new_cluster, "spark_conf", null)
          dynamic "azure_attributes" {
      
            for_each = lookup(var.job_clusters[job_cluster.key].new_cluster, "azure_attributes", null)[*]
            content {
              first_on_demand    = lookup(var.job_clusters[job_cluster.key].new_cluster.azure_attributes, "first_on_demand", null)
              availability       = lookup(var.job_clusters[job_cluster.key].new_cluster.azure_attributes, "availability", null)
              spot_bid_max_price = lookup(var.job_clusters[job_cluster.key].new_cluster.azure_attributes, "spot_bid_max_price", null)
            }
          }
          node_type_id        = lookup(var.job_clusters[job_cluster.key].new_cluster, "node_type_id", null)
          custom_tags         = lookup(var.job_clusters[job_cluster.key].new_cluster, "custom_tags", null)
          spark_env_vars      = lookup(var.job_clusters[job_cluster.key].new_cluster, "spark_env_vars", null)
          enable_elastic_disk = lookup(var.job_clusters[job_cluster.key].new_cluster, "enable_elastic_disk", null)
          data_security_mode  = lookup(var.job_clusters[job_cluster.key].new_cluster, "data_security_mode", null)
          runtime_engine      = lookup(var.job_clusters[job_cluster.key].new_cluster, "runtime_engine", null)
          num_workers         = lookup(var.job_clusters[job_cluster.key].new_cluster, "num_workers", null)

          dynamic "autoscale" {
      
            for_each = lookup(var.job_clusters[job_cluster.key].new_cluster, "autoscale", null)[*]
            content {
              min_workers = lookup(var.job_clusters[job_cluster.key].new_cluster.autoscale, "min_workers", null)
              max_workers = lookup(var.job_clusters[job_cluster.key].new_cluster.autoscale, "max_workers", null)
            }
          }
        }
      }
    }
  }

  dynamic "git_source" {
    for_each = var.git_source[*]
    content {
      url      = lookup(var.git_source, "git_source", null)
      provider = lookup(var.git_source, "provider", null)
      branch   = lookup(var.git_source, "branch", null)
      tag      = lookup(var.git_source, "tag", null)
      commit   = lookup(var.git_source, "commit", null)
    }
  }

  dynamic "continuous" {
    for_each = var.continuous[*]
    content {
      pause_status = var.ambiente == "prod" ? "UNPAUSED" : "PAUSED"
    }
  }

  dynamic "schedule" {
    for_each = var.schedule[*]
    content {
      quartz_cron_expression = lookup(var.schedule, "quartz_cron_expression", null)
      timezone_id            = lookup(var.schedule, "timezone_id", null)
      pause_status           = var.ambiente == "prod" ? "UNPAUSED" : "PAUSED"
    }
  }

  dynamic "trigger" {
    for_each = var.trigger[*]
    content {
      pause_status = var.ambiente == "prod" ? "UNPAUSED" : "PAUSED"
      dynamic "file_arrival" {
        for_each = lookup(var.trigger, "file_arrival", null)[*]
        content {
          url                               = lookup(var.trigger.file_arrival, "url", null)
          min_time_between_triggers_seconds = lookup(var.trigger.file_arrival, "min_time_between_triggers_seconds", null)
          wait_after_last_change_seconds    = lookup(var.trigger.file_arrival, "wait_after_last_change_seconds", null)
        }
      }
      dynamic "table_update" {
        for_each = lookup(var.trigger, "table_update", null)[*]
        content {
          table_names                       = lookup(var.trigger.table_update, "table_names", null)
          condition                         = lookup(var.trigger.table_update, "condition", null)
          min_time_between_triggers_seconds = lookup(var.trigger.table_update, "min_time_between_triggers_seconds", null)
          wait_after_last_change_seconds    = lookup(var.trigger.table_update, "wait_after_last_change_seconds", null)
        }
      }
    }
  }

  dynamic "task" {
    for_each = var.tasks[*]
    content {
      task_key                  = lookup(var.tasks[task.key], "task_key", null)
      run_if                    = lookup(var.tasks[task.key], "run_if", null)
      existing_cluster_id       = lookup(var.tasks[task.key], "existing_cluster_id", null)
      job_cluster_key           = lookup(var.tasks[task.key], "job_cluster_key", null)
      timeout_seconds           = lookup(var.tasks[task.key], "timeout_seconds", null)
      min_retry_interval_millis = lookup(var.tasks[task.key], "min_retry_interval_millis", null)
      max_retries               = lookup(var.tasks[task.key], "max_retries", null)
      retry_on_timeout          = lookup(var.tasks[task.key], "retry_on_timeout", null)

      dynamic "run_job_task" {
  
        for_each = lookup(var.tasks[task.key], "run_job_task", null)[*]
        content {
          job_id = lookup(var.tasks[task.key].run_job_task, "job_id", null)
        }
      }
      dynamic "library" {
  
        for_each = lookup(var.tasks[task.key], "libraries", null)[*]
        content {
          jar = lookup(var.tasks[task.key].libraries, "jar", null)
          dynamic "pypi" {
      
            for_each = lookup(var.tasks[task.key].libraries, "pypi", null)[*]
            content {
              package = lookup(var.tasks[task.key].libraries.pypi, "package", null)
              repo    = lookup(var.tasks[task.key].libraries.pypi, "repo", null)
            }
          }
          dynamic "cran" {
      
            for_each = lookup(var.tasks[task.key].libraries, "cran", null)[*]
            content {
              package = lookup(var.tasks[task.key].libraries.cran, "package", null)
              repo    = lookup(var.tasks[task.key].libraries.cran, "repo", null)
            }
          }
          dynamic "maven" {
      
            for_each = lookup(var.tasks[task.key].libraries, "maven", null)[*]
            content {
              coordinates = lookup(var.tasks[task.key].libraries.maven, "coordinates", null)
              exclusions  = lookup(var.tasks[task.key].libraries.maven, "exclusions", null)
              repo        = lookup(var.tasks[task.key].libraries.maven, "repo", null)
            }
          }
        }
      }
      dynamic "depends_on" {
  
        for_each = lookup(var.tasks[task.key], "depends_on", null)[*]
        content {
          task_key = lookup(var.tasks[task.key].depends_on[depends_on.key], "task_key", null)
          outcome  = lookup(var.tasks[task.key].depends_on[depends_on.key], "outcome", null)
        }
      }
      dynamic "notebook_task" {
  
        for_each = lookup(var.tasks[task.key], "notebook_task", null)[*]
        content {
          source          = lookup(var.tasks[task.key].notebook_task, "source", null)
          notebook_path   = lookup(var.tasks[task.key].notebook_task, "notebook_path", null)
          base_parameters = lookup(var.tasks[task.key].notebook_task, "base_parameters", null)
        }
      }
      dynamic "condition_task" {
  
        for_each = lookup(var.tasks[task.key], "condition_task", null)[*]
        content {
          left  = lookup(var.tasks[task.key].condition_task, "left", null)
          right = lookup(var.tasks[task.key].condition_task, "right", null)
          op    = lookup(var.tasks[task.key].condition_task, "op", null)
        }
      }
      dynamic "for_each_task" {
  
        for_each = lookup(var.tasks[task.key], "for_each_task", null)[*]
        content {
          inputs      = lookup(var.tasks[task.key].for_each_task, "inputs", null)
          concurrency = lookup(var.tasks[task.key].for_each_task, "concurrency", null)

          task {
            task_key                  = lookup(var.tasks[task.key].for_each_task.task, "task_key", null)
            run_if                    = lookup(var.tasks[task.key].for_each_task.task, "run_if", null)
            existing_cluster_id       = lookup(var.tasks[task.key].for_each_task.task, "existing_cluster_id", null)
            job_cluster_key           = lookup(var.tasks[task.key].for_each_task.task, "job_cluster_key", null)
            timeout_seconds           = lookup(var.tasks[task.key].for_each_task.task, "timeout_seconds", null)
            min_retry_interval_millis = lookup(var.tasks[task.key].for_each_task.task, "min_retry_interval_millis", null)
            max_retries               = lookup(var.tasks[task.key].for_each_task.task, "max_retries", null)
            retry_on_timeout          = lookup(var.tasks[task.key].for_each_task.task, "retry_on_timeout", null)

            dynamic "run_job_task" {
        
              for_each = lookup(var.tasks[task.key].for_each_task.task, "run_job_task", null)[*]
              content {
                job_id = lookup(var.tasks[task.key].for_each_task.task.run_job_task, "job_id", null)
              }
            }
            dynamic "library" {
        
              for_each = lookup(var.tasks[task.key].for_each_task.task, "libraries", null)[*]
              content {
                jar = lookup(var.tasks[task.key].for_each_task.task.libraries, "jar", null)
                dynamic "pypi" {
            
                  for_each = lookup(var.tasks[task.key].for_each_task.task.libraries, "pypi", null)[*]
                  content {
                    package = lookup(var.tasks[task.key].for_each_task.task.libraries.pypi, "package", null)
                    repo    = lookup(var.tasks[task.key].for_each_task.task.libraries.pypi, "repo", null)
                  }
                }
                dynamic "cran" {
            
                  for_each = lookup(var.tasks[task.key].for_each_task.task.libraries, "cran", null)[*]
                  content {
                    package = lookup(var.tasks[task.key].for_each_task.task.libraries.cran, "package", null)
                    repo    = lookup(var.tasks[task.key].for_each_task.task.libraries.cran, "repo", null)
                  }
                }
                dynamic "maven" {
            
                  for_each = lookup(var.tasks[task.key].for_each_task.task.libraries, "maven", null)[*]
                  content {
                    coordinates = lookup(var.tasks[task.key].for_each_task.task.libraries.maven, "coordinates", null)
                    exclusions  = lookup(var.tasks[task.key].for_each_task.task.libraries.maven, "exclusions", null)
                    repo        = lookup(var.tasks[task.key].for_each_task.task.libraries.maven, "repo", null)
                  }
                }
              }
            }
            dynamic "depends_on" {
        
              for_each = lookup(var.tasks[task.key].for_each_task.task, "depends_on", null)[*]
              content {
                task_key = lookup(var.tasks[task.key].for_each_task.task.depends_on[depends_on.key], "task_key", null)
                outcome  = lookup(var.tasks[task.key].for_each_task.task.depends_on[depends_on.key], "outcome", null)
              }
            }
            dynamic "notebook_task" {
        
              for_each = lookup(var.tasks[task.key].for_each_task.task, "notebook_task", null)[*]
              content {
                source          = lookup(var.tasks[task.key].for_each_task.task.notebook_task, "source", null)
                notebook_path   = lookup(var.tasks[task.key].for_each_task.task.notebook_task, "notebook_path", null)
                base_parameters = lookup(var.tasks[task.key].for_each_task.task.notebook_task, "base_parameters", null)
              }
            }
            dynamic "condition_task" {
        
              for_each = lookup(var.tasks[task.key].for_each_task.task, "condition_task", null)[*]
              content {
                left  = lookup(var.tasks[task.key].for_each_task.task.condition_task, "left", null)
                right = lookup(var.tasks[task.key].for_each_task.task.condition_task, "right", null)
                op    = lookup(var.tasks[task.key].for_each_task.task.condition_task, "op", null)
              }
            }
            dynamic "pipeline_task" {
        
              for_each = lookup(var.tasks[task.key].for_each_task.task, "pipeline_task", null)[*]
              content {
                pipeline_id = lookup(var.tasks[task.key].for_each_task.task.pipeline_task, "pipeline_id", null)
              }
            }
            dynamic "sql_task" {
        
              for_each = lookup(var.tasks[task.key].for_each_task.task, "sql_task", null)[*]
              content {
                warehouse_id = lookup(var.tasks[task.key].for_each_task.task.sql_task, "warehouse_id", null)
                parameters   = lookup(var.tasks[task.key].for_each_task.task.sql_task, "parameters", null)
                dynamic "query" {
            
                  for_each = lookup(var.tasks[task.key].for_each_task.task.sql_task, "query", null)[*]
                  content {
                    query_id = lookup(var.tasks[task.key].for_each_task.task.sql_task.query, "query_id", null)
                  }
                }
                dynamic "dashboard" {
            
                  for_each = lookup(var.tasks[task.key].for_each_task.task.sql_task, "dashboard", null)[*]
                  content {
                    dashboard_id = lookup(var.tasks[task.key].for_each_task.task.sql_task.dashboard, "dashboard_id", null)
                  }
                }
                dynamic "alert" {
            
                  for_each = lookup(var.tasks[task.key].for_each_task.task.sql_task, "alert", null)[*]
                  content {
                    subscriptions {
                      user_name = lookup(var.tasks[task.key].for_each_task.task.sql_task.alert.subscriptions, "user_name", null)
                    }
                    alert_id            = lookup(var.tasks[task.key].for_each_task.task.sql_task.alert, "alert_id", null)
                    pause_subscriptions = lookup(var.tasks[task.key].for_each_task.task.sql_task.alert, "pause_subscriptions", null)
                  }
                }
                dynamic "file" {
            
                  for_each = lookup(var.tasks[task.key].for_each_task.task.sql_task, "file", null)[*]
                  content {
                    path = lookup(var.tasks[task.key].for_each_task.task.sql_task.file, "path", null)[*]
                  }
                }
              }
            }
            dynamic "python_wheel_task" {
        
              for_each = lookup(var.tasks[task.key].for_each_task.task, "python_wheel_task", null)[*]
              content {
                entry_point      = lookup(var.tasks[task.key].for_each_task.task.python_wheel_task, "entry_point", null)
                package_name     = lookup(var.tasks[task.key].for_each_task.task.python_wheel_task, "package_name", null)
                parameters       = lookup(var.tasks[task.key].for_each_task.task.python_wheel_task, "parameters", null)
                named_parameters = lookup(var.tasks[task.key].for_each_task.task.python_wheel_task, "named_parameters", null)
              }
            }
            dynamic "dbt_task" {
        
              for_each = lookup(var.tasks[task.key].for_each_task.task, "dbt_task", null)[*]
              content {
                commands           = lookup(var.tasks[task.key].for_each_task.task.dbt_task, "commands", null)
                project_directory  = lookup(var.tasks[task.key].for_each_task.task.dbt_task, "project_directory", null)
                profiles_directory = lookup(var.tasks[task.key].for_each_task.task.dbt_task, "profiles_directory", null)
                catalog            = lookup(var.tasks[task.key].for_each_task.task.dbt_task, "catalog", null)
                schema             = lookup(var.tasks[task.key].for_each_task.task.dbt_task, "schema", null)
                warehouse_id       = lookup(var.tasks[task.key].for_each_task.task.dbt_task, "warehouse_id", null)
              }
            }
            dynamic "email_notifications" {
        
              for_each = lookup(var.tasks[task.key].for_each_task.task, "email_notifications", null)[*]
              content {
                on_start   = lookup(var.tasks[task.key].for_each_task.task.email_notifications, "on_start", null)
                on_success = lookup(var.tasks[task.key].for_each_task.task.email_notifications, "on_success", null)
                on_failure = strcontains(var.name, "streaming") == true ? lookup(var.tasks[task.key].for_each_task.task.email_notifications, "on_failure", null) != null ? distinct(concat(var.tasks[task.key].for_each_task.task.email_notifications.on_failure, var.destinatarios_alertas_streaming)) : var.destinatarios_alertas_streaming : lookup(var.tasks[task.key].for_each_task.task.email_notifications, "on_failure", null)
              }
            }
            dynamic "spark_jar_task" {
        
              for_each = lookup(var.tasks[task.key].for_each_task.task, "spark_jar_task", null)[*]
              content {
                parameters      = lookup(var.tasks[task.key].for_each_task.task.spark_jar_task, "parameters", null)
                main_class_name = lookup(var.tasks[task.key].for_each_task.task.spark_jar_task, "main_class_name", null)
              }
            }
            dynamic "spark_submit_task" {
        
              for_each = lookup(var.tasks[task.key].for_each_task.task, "spark_submit_task", null)[*]
              content {
                parameters = lookup(var.tasks[task.key].for_each_task.task.spark_submit_task, "parameters", null)
              }
            }
            dynamic "spark_python_task" {
        
              for_each = lookup(var.tasks[task.key].for_each_task.task, "spark_python_task", null)[*]
              content {
                python_file = lookup(var.tasks[task.key].for_each_task.task.spark_python_task, "python_file", null)
                parameters  = lookup(var.tasks[task.key].for_each_task.task.spark_python_task, "parameters", null)
                source      = lookup(var.tasks[task.key].for_each_task.task.spark_python_task, "source", null)
              }
            }
            dynamic "health" {
        
              for_each = lookup(var.tasks[task.key].for_each_task.task, "health", null)[*]
              content {
                rules {
                  metric = lookup(var.tasks[task.key].for_each_task.task.health.rules[0], "metric", null)
                  op     = lookup(var.tasks[task.key].for_each_task.task.health.rules[0], "op", null)
                  value  = lookup(var.tasks[task.key].for_each_task.task.health.rules[0], "value", null)
                }
              }
            }
            dynamic "notification_settings" {
        
              for_each = lookup(var.tasks[task.key].for_each_task.task, "notification_settings", null)[*]
              content {
                no_alert_for_skipped_runs  = lookup(var.tasks[task.key].for_each_task.task.notification_settings, "no_alert_for_skipped_runs", true)
                no_alert_for_canceled_runs = lookup(var.tasks[task.key].for_each_task.task.notification_settings, "no_alert_for_canceled_runs", true)
                alert_on_last_attempt      = lookup(var.tasks[task.key].for_each_task.task.notification_settings, "alert_on_last_attempt", null)
              }
            }
          }

        }
      }
      dynamic "pipeline_task" {
  
        for_each = lookup(var.tasks[task.key], "pipeline_task", null)[*]
        content {
          pipeline_id = lookup(var.tasks[task.key].pipeline_task, "pipeline_id", null)
        }
      }
      dynamic "sql_task" {
  
        for_each = lookup(var.tasks[task.key], "sql_task", null)[*]
        content {
          warehouse_id = lookup(var.tasks[task.key].sql_task, "warehouse_id", null)
          parameters   = lookup(var.tasks[task.key].sql_task, "parameters", null)
          dynamic "query" {
      
            for_each = lookup(var.tasks[task.key].sql_task, "query", null)[*]
            content {
              query_id = lookup(var.tasks[task.key].sql_task.query, "query_id", null)
            }
          }
          dynamic "dashboard" {
      
            for_each = lookup(var.tasks[task.key].sql_task, "dashboard", null)[*]
            content {
              dashboard_id = lookup(var.tasks[task.key].sql_task.dashboard, "dashboard_id", null)
            }
          }
          dynamic "alert" {
      
            for_each = lookup(var.tasks[task.key].sql_task, "alert", null)[*]
            content {
              subscriptions {
                user_name = lookup(var.tasks[task.key].sql_task.alert.subscriptions, "user_name", null)
              }
              alert_id            = lookup(var.tasks[task.key].sql_task.alert, "alert_id", null)
              pause_subscriptions = lookup(var.tasks[task.key].sql_task.alert, "pause_subscriptions", null)
            }
          }
          dynamic "file" {
      
            for_each = lookup(var.tasks[task.key].sql_task, "file", null)[*]
            content {
              path = lookup(var.tasks[task.key].sql_task.file, "path", null)[*]
            }
          }
        }
      }
      dynamic "python_wheel_task" {
  
        for_each = lookup(var.tasks[task.key], "python_wheel_task", null)[*]
        content {
          entry_point      = lookup(var.tasks[task.key].python_wheel_task, "entry_point", null)
          package_name     = lookup(var.tasks[task.key].python_wheel_task, "package_name", null)
          parameters       = lookup(var.tasks[task.key].python_wheel_task, "parameters", null)
          named_parameters = lookup(var.tasks[task.key].python_wheel_task, "named_parameters", null)
        }
      }
      dynamic "dbt_task" {
  
        for_each = lookup(var.tasks[task.key], "dbt_task", null)[*]
        content {
          commands           = lookup(var.tasks[task.key].dbt_task, "commands", null)
          project_directory  = lookup(var.tasks[task.key].dbt_task, "project_directory", null)
          profiles_directory = lookup(var.tasks[task.key].dbt_task, "profiles_directory", null)
          catalog            = lookup(var.tasks[task.key].dbt_task, "catalog", null)
          schema             = lookup(var.tasks[task.key].dbt_task, "schema", null)
          warehouse_id       = lookup(var.tasks[task.key].dbt_task, "warehouse_id", null)
        }
      }
      dynamic "email_notifications" {
  
        for_each = lookup(var.tasks[task.key], "email_notifications", null)[*]
        content {
          on_start   = lookup(var.tasks[task.key].email_notifications, "on_start", null)
          on_success = lookup(var.tasks[task.key].email_notifications, "on_success", null)
          on_failure = strcontains(var.name, "streaming") == true ? lookup(var.tasks[task.key].email_notifications, "on_failure", null) != null ? distinct(concat(var.tasks[task.key].email_notifications.on_failure, var.destinatarios_alertas_streaming)) : var.destinatarios_alertas_streaming : lookup(var.tasks[task.key].email_notifications, "on_failure", null)
        }
      }
      dynamic "spark_jar_task" {
  
        for_each = lookup(var.tasks[task.key], "spark_jar_task", null)[*]
        content {
          parameters      = lookup(var.tasks[task.key].spark_jar_task, "parameters", null)
          main_class_name = lookup(var.tasks[task.key].spark_jar_task, "main_class_name", null)
        }
      }
      dynamic "spark_submit_task" {
  
        for_each = lookup(var.tasks[task.key], "spark_submit_task", null)[*]
        content {
          parameters = lookup(var.tasks[task.key].spark_submit_task, "parameters", null)
        }
      }
      dynamic "spark_python_task" {
  
        for_each = lookup(var.tasks[task.key], "spark_python_task", null)[*]
        content {
          python_file = lookup(var.tasks[task.key].spark_python_task, "python_file", null)
          parameters  = lookup(var.tasks[task.key].spark_python_task, "parameters", null)
          source      = lookup(var.tasks[task.key].spark_python_task, "source", null)
        }
      }
      dynamic "health" {
  
        for_each = lookup(var.tasks[task.key], "health", null)[*]
        content {
          rules {
            metric = lookup(var.tasks[task.key].health.rules[0], "metric", null)
            op     = lookup(var.tasks[task.key].health.rules[0], "op", null)
            value  = lookup(var.tasks[task.key].health.rules[0], "value", null)
          }
        }
      }
      dynamic "notification_settings" {
  
        for_each = lookup(var.tasks[task.key], "notification_settings", null)[*]
        content {
          no_alert_for_skipped_runs  = lookup(var.tasks[task.key].notification_settings, "no_alert_for_skipped_runs", true)
          no_alert_for_canceled_runs = lookup(var.tasks[task.key].notification_settings, "no_alert_for_canceled_runs", true)
          alert_on_last_attempt      = lookup(var.tasks[task.key].notification_settings, "alert_on_last_attempt", null)
        }
      }
    }
  }

  dynamic "queue" {
    for_each = var.queue[*]
    content {
      enabled = lookup(var.queue, "enabled", null)
    }
  }

  dynamic "run_as" {
    for_each = var.run_as[*]
    content {
      user_name              = var.ambiente == "lab" ? lookup(var.run_as, "user_name", null) : "prod-user@org.com.br"
      # user_name              = contains(keys(run_as.value), "user_name") ? var.ambiente == "lab" ? lookup(var.run_as, "user_name", null) : "prod-user@org.com.br" : null
      # service_principal_name = contains(keys(run_as.value), "service_principal_name") ? var.ambiente == "lab" ? lookup(var.run_as, "service_principal_name", null) : "4e663b04-4caa-4abc-b49e-c194d4f0f545" : null
    }
  }

  dynamic "notification_settings" {
    for_each = var.notification_settings[*]
    content {
      no_alert_for_skipped_runs  = lookup(var.notification_settings, "no_alert_for_skipped_runs", true)
      no_alert_for_canceled_runs = lookup(var.notification_settings, "no_alert_for_canceled_runs", true)
    }
  }

  dynamic "email_notifications" {
    for_each = var.email_notifications[*]
    content {
      on_start   = lookup(var.email_notifications, "on_start", null)
      on_success = lookup(var.email_notifications, "on_success", null)
      on_failure = lookup(var.email_notifications, "on_failure", null) != null ? distinct(concat(var.email_notifications.on_failure, var.destinatarios_alertas)) : var.destinatarios_alertas
      # no_alert_for_skipped_runs = lookup(var.email_notifications, "no_alert_for_skipped_runs", true)
    }
  }

  webhook_notifications {

    dynamic "on_start" {

      for_each = lookup(var.webhook_notifications, "on_start", null)[*]
      content {
        id = on_start.value.id
      }
    }
    dynamic "on_success" {

      for_each = lookup(var.webhook_notifications, "on_success", null)[*]
      content {
        id = on_success.value.id
      }
    }
    dynamic "on_failure" {

      #for_each = length(lookup(var.webhook_destinations, "on_failure", [])) > 0 ? concat([for item in lookup(var.webhook_notifications, "on_failure", []) : item], [for id in var.webhook_destinations : {"id" = id}]) : [for id in var.webhook_destinations : {"id" = id}]
      for_each = distinct(var.webhook_destinations[*])
      content {
        id = on_failure.value
      }
    }

  }
}
