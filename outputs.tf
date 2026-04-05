output "id" {
  description = "Cosmos DB account ID."
  value       = azurerm_cosmosdb_account.this.id
}

output "name" {
  description = "Cosmos DB account name."
  value       = azurerm_cosmosdb_account.this.name
}

output "endpoint" {
  description = "Cosmos DB account endpoint."
  value       = azurerm_cosmosdb_account.this.endpoint
}

output "identity_principal_id" {
  description = "Principal ID of the system-assigned managed identity."
  value       = azurerm_cosmosdb_account.this.identity[0].principal_id
}

output "private_endpoint_id" {
  description = "Private endpoint resource ID."
  value       = azurerm_private_endpoint.cosmos.id
}
