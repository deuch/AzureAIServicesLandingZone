resource "random_string" "azurerm_apim_name" {
  length  = 5
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "azurerm_resource_group" "apim" {
  location = local.location
  name     = "rg-apim"
  provider = azurerm
}

output "test" {
  description = "The endpoint used to connect to the Cognitive Service Account."
  value       = lookup(module.vnet_ai.vnet_subnets_name_id, "snet_web")
}
resource "azurerm_api_management" "example" {
  name                = "apim-openai-services-${random_string.azurerm_apim_name.result}"
  location            = local.location
  resource_group_name = azurerm_resource_group.apim.name
  publisher_name      = "My Company"
  publisher_email     = "company@terraform.io"

  sku_name = "Developer_1"

  virtual_network_type = "Internal"

  virtual_network_configuration {
    subnet_id = lookup(module.vnet_ai.vnet_subnets_name_id, "snet_web")
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [module.vnet_ai, azurerm_route_table.rt_web]
}

resource "azurerm_log_analytics_workspace" "apim-law" {
  name                = "logs-apim"
  location            = local.location
  resource_group_name = azurerm_resource_group.apim.name
}

resource "azurerm_monitor_diagnostic_setting" "apim-diag" {
  name               = "apim-diag"
  target_resource_id = azurerm_api_management.example.id 
  log_analytics_workspace_id = azurerm_log_analytics_workspace.apim-law.id 

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
  }
}


# Create DNS Zone and register it

resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = "azure-api.net"
  resource_group_name = azurerm_resource_group.apim.name

}


resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link_vnet" {

  name                  = "dns-link-vnet-ai"
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  resource_group_name   = azurerm_resource_group.apim.name
  virtual_network_id    = module.vnet_ai.vnet_id
  registration_enabled  = false
  
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link_hub" {

  name                  = "dns-link-vnet-hub"
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  resource_group_name   = azurerm_resource_group.apim.name
  virtual_network_id    = local.hub_vnet_id
  registration_enabled  = false

}



resource "azurerm_private_dns_a_record" "private_dns_a_record" {
  name                = "apim-openai-services-${random_string.azurerm_apim_name.result}"
  zone_name           = azurerm_private_dns_zone.private_dns_zone.name
  resource_group_name = azurerm_resource_group.apim.name
  ttl                 = 300
  records             = [azurerm_api_management.example.private_ip_addresses[0]]
}
