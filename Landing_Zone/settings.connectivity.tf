# Configure the connectivity resources settings.
locals {
  location                  = "westeurope"
  environment               = "dev"
  connectivity_subscription = var.connectivity_subscription

  configure_connectivity_resources = {
    settings = {
      hub_networks = [
        {
          enabled = true
          config = {
            address_space                = ["10.100.0.0/16", ]
            location                     = local.location
            link_to_ddos_protection_plan = false
            dns_servers                  = []
            bgp_community                = ""
            subnets = [{
              name = "AzureBastionSubnet"
              address_prefixes = [
                "10.100.1.0/26"
              ]
              network_security_group_id = ""
              route_table_id            = ""
              },
              {
                name = "SharedServicesSubnet"
                address_prefixes = [
                  "10.100.1.64/26"
                ]
                network_security_group_id = ""
                route_table_id            = ""
              }
            ]
            virtual_network_gateway = {
              enabled = false
              config = {
                address_prefix           = "10.100.1.0/24"
                gateway_sku_expressroute = "ErGw2AZ"
                gateway_sku_vpn          = ""
                advanced_vpn_settings = {
                  enable_bgp                       = null
                  active_active                    = null
                  private_ip_address_allocation    = ""
                  default_local_network_gateway_id = ""
                  vpn_client_configuration         = []
                  bgp_settings                     = []
                  custom_route                     = []
                }
              }
            }
            azure_firewall = {
              enabled = true
              config = {
                address_prefix                = "10.100.0.0/24"
                enable_dns_proxy              = true
                dns_servers                   = []
                sku_tier                      = ""
                base_policy_id                = ""
                private_ip_ranges             = []
                threat_intelligence_mode      = ""
                threat_intelligence_allowlist = []
                availability_zones = {
                  zone_1 = true
                  zone_2 = true
                  zone_3 = true
                }
              }
            }
            spoke_virtual_network_resource_ids      = []
            enable_outbound_virtual_network_peering = true
            enable_hub_network_mesh_peering         = false
          }
        },

      ]

      vwan_hub_networks = []
      ddos_protection_plan = {
        enabled = false
        config = {
          location = local.location
        }
      }
      dns = {
        enabled = true
        config = {
          location = local.location
          enable_private_link_by_service = {

            azure_api_management = true
            azure_bot_service_bot                = false
            azure_bot_service_token              = false
            azure_cache_for_redis                = false
            azure_cache_for_redis_enterprise     = false
            azure_container_registry             = false
            azure_cosmos_db_cassandra            = false
            azure_cosmos_db_gremlin              = false
            azure_cosmos_db_mongodb              = false
            azure_cosmos_db_sql                  = false
            azure_cosmos_db_table                = false
            azure_data_explorer                  = false
            azure_data_factory                   = false
            azure_data_factory_portal            = false
            azure_data_health_data_services      = false
            azure_data_lake_file_system_gen2     = false
            azure_database_for_mariadb_server    = false
            azure_database_for_mysql_server      = false
            azure_database_for_postgresql_server = false
            azure_event_grid_domain              = false
            azure_event_grid_topic               = false
            azure_event_hubs_namespace           = false
            azure_hdinsights                     = false
            azure_key_vault                      = false
            azure_key_vault_managed_hsm          = false
            azure_kubernetes_service_management  = false
            azure_machine_learning_workspace     = false
            azure_managed_disks                  = false
            azure_monitor                        = false
            azure_search_service                 = false
            azure_service_bus_namespace          = false
            azure_sql_database_sqlserver         = false
            azure_synapse_analytics_dev          = false
            azure_synapse_analytics_sql          = false
            azure_synapse_studio                 = false
            azure_web_apps_sites                 = false
            azure_web_apps_static_sites          = false
            cognitive_services_account           = false
            microsoft_power_bi                   = false
            signalr                              = false
            signalr_webpubsub                    = false
            storage_account_blob                 = false
            storage_account_file                 = false
            storage_account_queue                = false
            storage_account_table                = false
            storage_account_web                  = false
            azure_key_vault = true
            azure_open_ai   = true
          }
          private_link_locations = [
            local.location
          ]
          public_dns_zones                                       = []
          private_dns_zones                                      = []
          enable_private_dns_zone_virtual_network_link_on_hubs   = true
          enable_private_dns_zone_virtual_network_link_on_spokes = false
          virtual_network_resource_ids_to_link                   = []
        }
      }
    }

    location = local.location
    tags     = var.connectivity_resources_tags
    advanced = null
  }
}
