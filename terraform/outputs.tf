###############################################################################
# FoundrLink Terraform — Outputs
# These are printed after `terraform apply` and can be used by CI/CD pipelines
###############################################################################

output "resource_group_name" {
  description = "Name of the Azure Resource Group"
  value       = azurerm_resource_group.main.name
}

output "vm_public_ip" {
  description = "Public IP address of the FoundrLink IIS web server VM"
  value       = azurerm_public_ip.web.ip_address
}

output "vm_fqdn" {
  description = "Fully Qualified Domain Name of the VM (configure your DNS CNAME to this)"
  value       = azurerm_public_ip.web.fqdn
}

output "sql_server_fqdn" {
  description = "Azure SQL Server FQDN — use this in your Web.config connection string"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "sql_database_name" {
  description = "Name of the Azure SQL Database"
  value       = azurerm_mssql_database.foundrlink.name
}

output "web_config_connection_string" {
  description = "Ready-to-paste Web.config connection string for FoundrLink"
  sensitive   = true
  value       = <<-EOT
    Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;
    Initial Catalog=FoundrLinkDb;
    Persist Security Info=False;
    User ID=${var.sql_admin_username};
    Password=${var.sql_admin_password};
    MultipleActiveResultSets=True;
    Encrypt=True;
    TrustServerCertificate=False;
    Connection Timeout=30;
  EOT
}

output "rdp_instructions" {
  description = "How to RDP into the VM"
  value       = "Open Remote Desktop (mstsc.exe) → connect to ${azurerm_public_ip.web.ip_address}:3389 → Username: ${var.vm_admin_username}"
}

output "auto_shutdown_time" {
  description = "VM auto-shutdown schedule (IST)"
  value       = "Daily at 10:30 PM IST (saves cost during off-hours)"
}

