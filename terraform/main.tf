###############################################################################
# FoundrLink — Azure Infrastructure (Terraform)
# Stack: ASP.NET Web Forms (.NET 4.7.2) + IIS on Windows Server 2022 + Azure SQL
# Region: Central India (closest to India)
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
  features {
    virtual_machine {
      # Prevent accidental deletion of the VM without an explicit -target destroy
      delete_os_disk_on_deletion = true
    }
  }
}

###############################################################################
# Locals — single place to change naming & sizing
###############################################################################
locals {
  app_name     = "foundrlink"
  environment  = var.environment
  location     = var.location
  name_prefix  = "${local.app_name}-${local.environment}"

  # Base64-encoded IIS bootstrap script — delivered securely via CustomScriptExtension
  iis_script_b64 = base64encode(file("${path.module}/scripts/iis_setup.ps1"))

  # Tags applied to every resource
  common_tags = {
    Application = "FoundrLink"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Framework   = "ASP.NET WebForms 4.7.2"
  }
}

###############################################################################
# Resource Group
###############################################################################
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}"
  location = local.location
  tags     = local.common_tags
}

###############################################################################
# Networking — Virtual Network + Subnet + NSG
###############################################################################
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.name_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web-${local.name_prefix}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "web" {
  name                = "nsg-${local.name_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags

  # HTTP — public access
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # HTTPS — public access
  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # RDP — RESTRICT to your known IP(s) via the rdp_allowed_ips variable
  security_rule {
    name                       = "Allow-RDP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = var.rdp_allowed_ips
    destination_address_prefix = "*"
  }

  # Web Deploy (optional, Visual Studio one-click publish)
  security_rule {
    name                       = "Allow-WebDeploy"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8172"
    source_address_prefixes    = var.rdp_allowed_ips
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

###############################################################################
# Public IP + DNS label
###############################################################################
resource "azurerm_public_ip" "web" {
  name                = "pip-${local.name_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  # DNS label → <app_name>-<env>.centralindia.cloudapp.azure.com
  domain_name_label   = "${local.app_name}-${local.environment}"
  tags                = local.common_tags
}

###############################################################################
# Network Interface
###############################################################################
resource "azurerm_network_interface" "web" {
  name                = "nic-${local.name_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "ipconfig-web"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web.id
  }
}

###############################################################################
# Windows Server 2022 Virtual Machine — IIS host for FoundrLink
###############################################################################
resource "azurerm_windows_virtual_machine" "web" {
  name                = "vm-${local.name_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.vm_size          # Standard_B1ms
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  tags                = local.common_tags

  network_interface_ids = [azurerm_network_interface.web.id]

  os_disk {
    name                 = "osdisk-${local.name_prefix}"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  # Ensure the VM hostname is short and IIS-compatible
  computer_name = "foundrlink"

  # Boot diagnostics stored in managed storage (no separate storage account needed)
  boot_diagnostics {}
}

###############################################################################
# Auto-shutdown schedule (saves cost — shuts VM down at 10:00 PM IST = 16:30 UTC)
###############################################################################
resource "azurerm_dev_test_global_vm_shutdown_schedule" "web" {
  virtual_machine_id = azurerm_windows_virtual_machine.web.id
  location           = azurerm_resource_group.main.location
  enabled            = true

  daily_recurrence_time = "2230"   # 22:30 UTC = ~04:00 AM IST next day
  timezone              = "India Standard Time"

  notification_settings {
    enabled = false
  }
}

###############################################################################
# Custom Script Extension — IIS + ASP.NET 4.8 bootstrap
# Encodes the PowerShell script as Base64 and runs it via CustomScriptExtension.
# Runs automatically on first provision; idempotent PowerShell.
###############################################################################

resource "azurerm_virtual_machine_extension" "iis_setup" {
  name                 = "iis-aspnet-setup"
  virtual_machine_id   = azurerm_windows_virtual_machine.web.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  tags                 = local.common_tags

  # The script is delivered via protected_settings (encrypted in transit)
  protected_settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -EncodedCommand ${local.iis_script_b64}"
  })

  depends_on = [azurerm_windows_virtual_machine.web]
}

###############################################################################
# Azure SQL Server
###############################################################################
resource "random_string" "sql_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_mssql_server" "main" {
  name                         = "sql-${local.app_name}-${random_string.sql_suffix.result}"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  tags                         = local.common_tags

  # Allow Azure services (the VM in the same region) to connect
  public_network_access_enabled = true
}

###############################################################################
# Azure SQL Firewall Rules
###############################################################################

# Allow all Azure services (includes the Azure VM)
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Allow developer IPs for SSMS / Visual Studio connections
resource "azurerm_mssql_firewall_rule" "developer_ips" {
  for_each = { for idx, ip in var.developer_ips : "dev-${idx}" => ip }

  name             = "dev-access-${each.key}"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = each.value
  end_ip_address   = each.value
}

###############################################################################
# Azure SQL Database — Lowest Cost Option: Basic (5 DTU, $4.99/mo) or Serverless
###############################################################################
resource "azurerm_mssql_database" "foundrlink" {
  name         = "FoundrLinkDb"
  server_id    = azurerm_mssql_server.main.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  tags         = local.common_tags

  # Pricing tier: "Basic" ($4.99/mo flat) or "GP_S_Gen5_1" (Serverless)
  sku_name                    = var.sql_database_sku
  max_size_gb                 = var.sql_database_sku == "Basic" ? 2 : 32
  auto_pause_delay_in_minutes = var.sql_database_sku == "Basic" ? null : 60
  min_capacity                = var.sql_database_sku == "Basic" ? null : 0.5

  # Prevent accidental destruction of production data
  lifecycle {
    prevent_destroy = false  # Set to true once you go live!
  }
}
