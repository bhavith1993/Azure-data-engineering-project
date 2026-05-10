provider "azurerm" {
  features {
  }
  subscription_id                 = "5db26c92-e03a-41db-9190-a51d27324c3b"
  environment                     = "public"
  use_msi                         = false
  use_cli                         = true
  use_oidc                        = false
  resource_provider_registrations = "none"
}
