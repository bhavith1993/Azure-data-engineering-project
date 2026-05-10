resource "azurerm_resource_group" "res-0" {
  location = "westus2"
  name     = "azureproject1"
}
resource "azurerm_data_factory" "res-1" {
  location            = "westus2"
  name                = "adf-azureproject2201"
  resource_group_name = azurerm_resource_group.res-0.name
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_data_factory_dataset_delimited_text" "res-2" {
  data_factory_id     = azurerm_data_factory.res-1.id
  first_row_as_header = true
  linked_service_name = "ls_adls"
  name                = "DelimitedText1"
  parameters = {
    p_file_name   = ""
    p_sink_folder = ""
  }
  azure_blob_fs_location {
    dynamic_filename_enabled = true
    dynamic_path_enabled     = true
    file_system              = "bronze"
    filename                 = "@dataset().p_file_name"
    path                     = "@dataset().p_sink_folder"
  }
}
resource "azurerm_data_factory_dataset_json" "res-4" {
  data_factory_id     = azurerm_data_factory.res-1.id
  linked_service_name = "ls_adls"
  name                = "ds_parameters"
}
resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "res-5" {
  data_factory_id = azurerm_data_factory.res-1.id
  name            = "ls_adls"
  url             = "https://storagedatalake2201.dfs.core.windows.net/"
}
resource "azurerm_data_factory_linked_custom_service" "res-6" {
  data_factory_id = azurerm_data_factory.res-1.id
  name            = "ls_github"
  type            = "HttpServer"
}
resource "azurerm_data_factory_pipeline" "res-7" {
  activities_json = jsonencode([{
    dependsOn = [{
      activity             = "LookupGit"
      dependencyConditions = ["Succeeded"]
    }]
    name = "ForeachGit"
    type = "ForEach"
    typeProperties = {
      activities = [{
        dependsOn = []
        inputs = [{
          parameters = {
            p_rel_url = {
              type  = "Expression"
              value = "@item().p_rel_url"
            }
          }
          referenceName = "ds_http"
          type          = "DatasetReference"
        }]
        name = "CopyRawData"
        outputs = [{
          parameters = {
            p_file_name = {
              type  = "Expression"
              value = "@item().p_file_name"
            }
            p_sink_folder = {
              type  = "Expression"
              value = "@item().p_sink_folder"
            }
          }
          referenceName = "DelimitedText1"
          type          = "DatasetReference"
        }]
        policy = {
          retry                  = 0
          retryIntervalInSeconds = 30
          secureInput            = false
          secureOutput           = false
          timeout                = "0.12:00:00"
        }
        type = "Copy"
        typeProperties = {
          enableStaging = false
          sink = {
            formatSettings = {
              fileExtension = ".txt"
              quoteAllText  = true
              type          = "DelimitedTextWriteSettings"
            }
            storeSettings = {
              type = "AzureBlobFSWriteSettings"
            }
            type = "DelimitedTextSink"
          }
          source = {
            formatSettings = {
              compressionProperties = null
              type                  = "DelimitedTextReadSettings"
            }
            storeSettings = {
              requestMethod = "GET"
              type          = "HttpReadSettings"
            }
            type = "DelimitedTextSource"
          }
          translator = {
            type           = "TabularTranslator"
            typeConversion = true
            typeConversionSettings = {
              allowDataTruncation  = true
              treatBooleanAsNumber = false
            }
          }
        }
        userProperties = []
      }]
      isSequential = true
      items = {
        type  = "Expression"
        value = "@activity('LookupGit').output.value"
      }
    }
    userProperties = []
    }, {
    dependsOn = []
    name      = "LookupGit"
    policy = {
      retry                  = 0
      retryIntervalInSeconds = 30
      secureInput            = false
      secureOutput           = false
      timeout                = "0.12:00:00"
    }
    type = "Lookup"
    typeProperties = {
      dataset = {
        parameters    = {}
        referenceName = "ds_parameters"
        type          = "DatasetReference"
      }
      firstRowOnly = false
      source = {
        formatSettings = {
          compressionProperties = null
          type                  = "JsonReadSettings"
        }
        storeSettings = {
          enablePartitionDiscovery = false
          recursive                = true
          type                     = "AzureBlobFSReadSettings"
        }
        type = "JsonSource"
      }
    }
    userProperties = []
  }])
  data_factory_id = azurerm_data_factory.res-1.id
  name            = "gittoraw"
}
resource "azurerm_databricks_workspace" "res-8" {
  location            = "westus2"
  name                = "adb-azure-project1"
  resource_group_name = azurerm_resource_group.res-0.name
  sku                 = "premium"
}
resource "azurerm_storage_account" "res-9" {
  account_replication_type        = "RAGRS"
  account_tier                    = "Standard"
  allow_nested_items_to_be_public = false
  is_hns_enabled                  = true
  location                        = "westus2"
  name                            = "dfltsynapsestorage"
  resource_group_name             = azurerm_resource_group.res-0.name
}
resource "azurerm_storage_container" "res-11" {
  name               = "dfltfilesystem"
  storage_account_id = "/subscriptions/5db26c92-e03a-41db-9190-a51d27324c3b/resourceGroups/azureproject1/providers/Microsoft.Storage/storageAccounts/dfltsynapsestorage"
  depends_on = [
    # One of azurerm_storage_account.res-9,azurerm_storage_account_queue_properties.res-13 (can't auto-resolve as their ids are identical)
  ]
}
resource "azurerm_storage_account_queue_properties" "res-13" {
  storage_account_id = azurerm_storage_account.res-9.id
  hour_metrics {
    version = "1.0"
  }
  logging {
    delete  = false
    read    = false
    version = "1.0"
    write   = false
  }
  minute_metrics {
    version = "1.0"
  }
}
resource "azurerm_storage_account" "res-15" {
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  allow_nested_items_to_be_public = false
  is_hns_enabled                  = true
  location                        = "westus2"
  name                            = "storagedatalake2201"
  resource_group_name             = azurerm_resource_group.res-0.name
}
resource "azurerm_storage_container" "res-17" {
  name               = "bronze"
  storage_account_id = "/subscriptions/5db26c92-e03a-41db-9190-a51d27324c3b/resourceGroups/azureproject1/providers/Microsoft.Storage/storageAccounts/storagedatalake2201"
  depends_on = [
    # One of azurerm_storage_account.res-15,azurerm_storage_account_queue_properties.res-22 (can't auto-resolve as their ids are identical)
  ]
}
resource "azurerm_storage_container" "res-18" {
  name               = "gold"
  storage_account_id = "/subscriptions/5db26c92-e03a-41db-9190-a51d27324c3b/resourceGroups/azureproject1/providers/Microsoft.Storage/storageAccounts/storagedatalake2201"
  depends_on = [
    # One of azurerm_storage_account.res-15,azurerm_storage_account_queue_properties.res-22 (can't auto-resolve as their ids are identical)
  ]
}
resource "azurerm_storage_container" "res-19" {
  name               = "parameters"
  storage_account_id = "/subscriptions/5db26c92-e03a-41db-9190-a51d27324c3b/resourceGroups/azureproject1/providers/Microsoft.Storage/storageAccounts/storagedatalake2201"
  depends_on = [
    # One of azurerm_storage_account.res-15,azurerm_storage_account_queue_properties.res-22 (can't auto-resolve as their ids are identical)
  ]
}
resource "azurerm_storage_container" "res-20" {
  name               = "silver"
  storage_account_id = "/subscriptions/5db26c92-e03a-41db-9190-a51d27324c3b/resourceGroups/azureproject1/providers/Microsoft.Storage/storageAccounts/storagedatalake2201"
  depends_on = [
    # One of azurerm_storage_account.res-15,azurerm_storage_account_queue_properties.res-22 (can't auto-resolve as their ids are identical)
  ]
}
resource "azurerm_storage_account_queue_properties" "res-22" {
  storage_account_id = azurerm_storage_account.res-15.id
  hour_metrics {
    version = "1.0"
  }
  logging {
    delete  = false
    read    = false
    version = "1.0"
    write   = false
  }
  minute_metrics {
    version = "1.0"
  }
}
resource "azurerm_synapse_workspace" "res-24" {
  location                             = "westus2"
  name                                 = "azureproject-synapse"
  resource_group_name                  = azurerm_resource_group.res-0.name
  sql_administrator_login              = "sqladminuser"
  storage_data_lake_gen2_filesystem_id = "https://dfltsynapsestorage.dfs.core.windows.net/dfltfilesystem"
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_synapse_workspace_extended_auditing_policy" "res-28" {
  log_monitoring_enabled = false
  synapse_workspace_id   = azurerm_synapse_workspace.res-24.id
}
resource "azurerm_synapse_firewall_rule" "res-29" {
  end_ip_address       = "255.255.255.255"
  name                 = "allowAll"
  start_ip_address     = "0.0.0.0"
  synapse_workspace_id = azurerm_synapse_workspace.res-24.id
}
resource "azurerm_synapse_integration_runtime_azure" "res-30" {
  location             = "AutoResolve"
  name                 = "AutoResolveIntegrationRuntime"
  synapse_workspace_id = azurerm_synapse_workspace.res-24.id
}
resource "azurerm_synapse_workspace_security_alert_policy" "res-31" {
  policy_state         = "Disabled"
  synapse_workspace_id = azurerm_synapse_workspace.res-24.id
}
resource "azurerm_synapse_workspace_vulnerability_assessment" "res-32" {
  storage_container_path             = ""
  workspace_security_alert_policy_id = azurerm_synapse_workspace_security_alert_policy.res-31.id
}
