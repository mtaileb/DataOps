locals {
  keyvault_policy_owners = concat([azuread_service_principal.my_service_principle.object_id], [data.azurerm_client_config.primary.object_id])
}