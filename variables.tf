# ── Identity ──────────────────────────────────────────────────────────
variable "name" {
  type        = string
  description = "Cosmos DB account name."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

# ── Networking ────────────────────────────────────────────────────────
variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint."
}

variable "virtual_network_id" {
  type        = string
  description = "Virtual network ID for private DNS zone link."
}

variable "create_private_dns_zones" {
  type        = bool
  description = "Create private DNS zones for the Cosmos DB private endpoint. Set false if centrally managed."
  default     = true
}

variable "private_dns_zone_ids" {
  type        = map(string)
  description = "Existing private DNS zone IDs keyed by subresource name when create_private_dns_zones = false."
  default     = {}
}

# ── Service-specific ──────────────────────────────────────────────────
variable "consistency_level" {
  type        = string
  description = "Default consistency level: BoundedStaleness, ConsistentPrefix, Eventual, Session, Strong."
  default     = "Session"
  validation {
    condition     = contains(["BoundedStaleness", "ConsistentPrefix", "Eventual", "Session", "Strong"], var.consistency_level)
    error_message = "consistency_level must be one of: BoundedStaleness, ConsistentPrefix, Eventual, Session, Strong."
  }
}

variable "minimal_tls_version" {
  type        = string
  description = "Minimum TLS version. I.AZR.0313 requires TLS 1.2."
  default     = "Tls12"
  validation {
    condition     = contains(["Tls11", "Tls12"], var.minimal_tls_version)
    error_message = "minimal_tls_version must be 'Tls11' or 'Tls12'."
  }
}

# ── Operational ───────────────────────────────────────────────────────
variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID for diagnostic logs. Empty string to skip."
  default     = ""
}

# ── Tags ──────────────────────────────────────────────────────────────
variable "tags" {
  type        = map(string)
  description = "Resource tags."
  default     = {}
}
