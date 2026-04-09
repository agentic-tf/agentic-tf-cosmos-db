locals {
  private_dns_zone_ids = var.create_private_dns_zones ? {
    Sql = azurerm_private_dns_zone.cosmos[0].id
  } : var.private_dns_zone_ids
}

resource "azurerm_cosmosdb_account" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = var.consistency_level
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  # ── Security hardening ────────────────────────────────────────────────
  # I.AZR.0257 / I.AZR.0033 — no public access
  public_network_access_enabled = false

  # I.AZR.0246 — Entra ID only; disable local (key-based) auth
  local_authentication_disabled = true

  # I.AZR.0313 — minimum TLS 1.2
  minimal_tls_version = var.minimal_tls_version

  # I.AZR.0032 — only approved VNets
  is_virtual_network_filter_enabled     = true
  network_acl_bypass_for_azure_services = true

  # I.AZR.0019 — Managed Identity
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# ── Private Endpoint ──────────────────────────────────────────────────
resource "azurerm_private_endpoint" "cosmos" {
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = azurerm_cosmosdb_account.this.id
    subresource_names              = ["Sql"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = contains(keys(local.private_dns_zone_ids), "Sql") ? [1] : []
    content {
      name                 = "cosmos-dns-group"
      private_dns_zone_ids = [local.private_dns_zone_ids["Sql"]]
    }
  }

  tags = var.tags
}

# ── Private DNS Zone ──────────────────────────────────────────────────
resource "azurerm_private_dns_zone" "cosmos" {
  count               = var.create_private_dns_zones ? 1 : 0
  name                = "privatelink.documents.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "cosmos" {
  count                 = var.create_private_dns_zones ? 1 : 0
  name                  = "${var.name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.cosmos[0].name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false
  tags                  = var.tags
}

# ── Diagnostic Settings (I.AZR.0013) ─────────────────────────────────
resource "azurerm_monitor_diagnostic_setting" "cosmos" {
  count = var.log_analytics_workspace_id != "" ? 1 : 0

  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_cosmosdb_account.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "DataPlaneRequests"
  }

  enabled_log {
    category = "QueryRuntimeStatistics"
  }

  enabled_log {
    category = "ControlPlaneRequests"
  }

  enabled_metric {
    category = "Requests"
  }
}
