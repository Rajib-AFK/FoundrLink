output "resource_group_name" {
  description = "Azure Resource Group"
  value       = azurerm_resource_group.main.name
}

output "web_app_name" {
  description = "Azure Web App Name"
  value       = azurerm_windows_web_app.main.name
}

output "web_app_url" {
  description = "Default Azure Web App URL"
  value       = "https://${azurerm_windows_web_app.main.default_hostname}"
}

output "custom_domain" {
  description = "Target custom domain for FoundrLink"
  value       = "https://${var.custom_domain}"
}

output "custom_domain_verification_id" {
  description = "TXT verification code for custom domain binding"
  sensitive   = true
  value       = azurerm_windows_web_app.main.custom_domain_verification_id
}

output "sql_server_fqdn" {
  description = "Azure SQL Server Hostname"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "sql_database_name" {
  description = "Azure SQL Database Name"
  value       = azurerm_mssql_database.foundrlink.name
}

output "web_config_connection_string" {
  description = "Connection string for Web.config"
  sensitive   = true
  value       = <<-EOT
    Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=FoundrLinkDb;Persist Security Info=False;User ID=${var.sql_admin_username};Password=${var.sql_admin_password};MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
  EOT
}

output "dns_setup_instructions" {
  description = "DNS records to create in ripaldesign.studio DNS manager"
  sensitive   = true
  value       = <<-EOT
    To map foundrlink.ripaldesign.studio:
    1. CNAME Record:
       Name: foundrlink
       Value: ${azurerm_windows_web_app.main.default_hostname}
       (If using Cloudflare, set to Orange Cloud / Proxied to get free SSL and host-header routing on F1!)
    
    2. TXT Record (if binding directly on Azure D1+):
       Name: asuid.foundrlink
       Value: ${azurerm_windows_web_app.main.custom_domain_verification_id}
  EOT
}
