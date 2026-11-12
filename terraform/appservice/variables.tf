variable "environment" {
  description = "Deployment environment (prod, staging, dev)"
  type        = string
  default     = "dev"
}

variable "app_service_sku" {
  description = "App Service Plan SKU: 'F1' (Free tier, $0/month) or 'D1' (Shared tier, ~$9.49/mo with native custom domain)"
  type        = string
  default     = "F1"
}

variable "custom_domain" {
  description = "Custom domain name for the application"
  type        = string
  default     = "foundrlink.ripaldesign.studio"
}

variable "location" {
  description = "Azure region for all resources (e.g., centralindia, eastus, centralus)"
  type        = string
  default     = "centralindia"
}

variable "sql_admin_username" {
  description = "Azure SQL Server administrator login"
  type        = string
  default     = "foundr_admin"
}

variable "sql_admin_password" {
  description = "Azure SQL Server administrator password"
  type        = string
  sensitive   = true
}

variable "developer_ips" {
  description = "List of developer public IPs to whitelist in the Azure SQL Server firewall for SSMS/VS access"
  type        = list(string)
  default     = []
}
