resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  resource_group_name = azurerm_resource_group.apim.name
  location            = local.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_log_analytics_workspace" "appgw-law" {
  name                = "logs-appgw"
  location            = local.location
  resource_group_name = azurerm_resource_group.apim.name
}

resource "azurerm_application_gateway" "appgateway" {
  name                = "apgw-ai-services"
  resource_group_name = azurerm_resource_group.apim.name
  location            = local.location
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }
  gateway_ip_configuration {
    name      = "my-gateway-ip-config"
    subnet_id = lookup(module.vnet_ai.vnet_subnets_name_id, "snet_ag")
  }
  frontend_port {
    name = "my-frontend-port"
    port = 80
  }
  frontend_ip_configuration {
    name                 = "my-frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.example.id
  }
  backend_address_pool {
    name  = "my-backend-pool"
    fqdns = [trimsuffix(azurerm_private_dns_a_record.private_dns_a_record.fqdn, ".")] # Private IP of the APIM instance
  }
  backend_http_settings {
    name                  = "my-backend-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
    probe_name            = "http_probe_test"
    pick_host_name_from_backend_address=true
  }

  http_listener {
    name                           = "my-http-listener"
    frontend_ip_configuration_name = "my-frontend-ip-config"
    frontend_port_name             = "my-frontend-port"
    protocol                       = "Http"
    ssl_certificate_name           = null
  }

  request_routing_rule {
    name                       = "my-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "my-http-listener"
    backend_address_pool_name  = "my-backend-pool"
    backend_http_settings_name = "my-backend-http-settings"
    priority                   = 100
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"

  }

  probe {
    name                = "http_probe_test"
    host                = trimsuffix(azurerm_private_dns_a_record.private_dns_a_record.fqdn, ".")
    path                = "/status-0123456789abcdef"
    protocol            = "Http"
    interval            = 60
    timeout             = 15
    unhealthy_threshold = 2
    minimum_servers     = 2
    match {
      status_code = ["100-999"]
      body        = ""
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "appgw-diag" {
  name               = "appgw-diag"
  target_resource_id = azurerm_application_gateway.appgateway.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.appgw-law.id

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
  }
}
