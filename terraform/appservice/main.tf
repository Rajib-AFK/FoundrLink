###############################################################################
# FoundrLink — Azure App Service (Free F1) + Azure SQL (Basic 5 DTU)
# Total Estimated Cost: ~$4.99 / month (~₹415 INR)
###############################################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

locals {
  app_name    = "foundrlink"
  environment = var.environment
  location    = var.location
  name_prefix = "${local.app_name}-${local.environment}"

  common_tags = {
    Application = "FoundrLink"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Tier        = "Free-Compute-Ultra-Low-Cost"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}-appsvc"
  location = local.location
  tags     = local.common_tags
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# -----------------------------------------------------------------------------
# Azure App Service Plan — Windows (F1 Free or D1 Shared)
# -----------------------------------------------------------------------------
resource "azurerm_service_plan" "main" {
  name                = "asp-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Windows"
  sku_name            = var.app_service_sku
  tags                = local.common_tags
}

# -----------------------------------------------------------------------------
# Azure SQL Server + Firewall
# -----------------------------------------------------------------------------
resource "azurerm_mssql_server" "main" {
  name                         = "sql-${local.app_name}-${random_string.suffix.result}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  tags                         = local.common_tags

  public_network_access_enabled = true
}

# Allow Azure Services (including the Web App) to connect to SQL
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Allow developer IPs for SSMS / Visual Studio connections
resource "azurerm_mssql_firewall_rule" "developer_ips" {
  for_each         = { for idx, ip in var.developer_ips : "dev-${idx}" => ip }
  name             = "dev-access-${each.key}"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = each.value
  end_ip_address   = each.value
}

# -----------------------------------------------------------------------------
# Azure SQL Database — Basic Tier (5 DTU, 2 GB) = ~$4.99 / month fixed
# -----------------------------------------------------------------------------
resource "azurerm_mssql_database" "foundrlink" {
  name         = "FoundrLinkDb"
  server_id    = azurerm_mssql_server.main.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  sku_name     = "Basic"
  max_size_gb  = 2
  tags         = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

# -----------------------------------------------------------------------------
# Azure Windows Web App (.NET 4.8 / 4.7.2 Web Forms native runtime)
# -----------------------------------------------------------------------------
resource "azurerm_windows_web_app" "main" {
  name                = "app-${local.app_name}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  tags                = local.common_tags

  site_config {
    always_on = false # Always_on is not supported on F1 (Free) plan

    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v4.0" # Supports .NET Framework 4.7.2 & 4.8
    }

    default_documents = [
      "Default.aspx",
      "index.html"
    ]
  }

  connection_string {
    name  = "FoundrLinkDb"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=FoundrLinkDb;Persist Security Info=False;User ID=${var.sql_admin_username};Password=${var.sql_admin_password};MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }

  app_settings = {
    "ValidationSettings:UnobtrusiveValidationMode" = "None"
  }
}
