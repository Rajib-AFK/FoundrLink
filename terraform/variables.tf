###############################################################################
# FoundrLink Terraform — Variables
###############################################################################

variable "environment" {
  description = "Deployment environment (prod, staging, dev)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["prod", "staging", "dev"], var.environment)
    error_message = "environment must be one of: prod, staging, dev."
  }
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "centralindia"
}

variable "vm_size" {
  description = "Azure VM size for the IIS web server"
  type        = string
  default     = "Standard_B1ms"
}

variable "os_disk_type" {
  description = "Storage tier for the VM OS disk (StandardSSD_LRS is lowest cost SSD, Standard_LRS is HDD)"
  type        = string
  default     = "StandardSSD_LRS"
}

variable "sql_database_sku" {
  description = "Azure SQL Database pricing tier. 'Basic' is ~$4.99/mo fixed (recommended for minimum cost). 'GP_S_Gen5_1' is Serverless."
  type        = string
  default     = "Basic"
}

variable "vm_admin_username" {
  description = "Local administrator username for the Windows VM"
  type        = string
  default     = "foundrlink_admin"
}

variable "vm_admin_password" {
  description = "Local administrator password for the Windows VM (min 12 chars, upper+lower+digit+special)"
  type        = string
  sensitive   = true
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

variable "rdp_allowed_ips" {
  description = "List of public IP addresses (CIDR or single IPs) allowed to RDP and Web Deploy to the VM"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.rdp_allowed_ips) > 0
    error_message = "You must specify at least one IP in rdp_allowed_ips to allow RDP access. Find your public IP at https://whatismyipaddress.com/"
  }
}

variable "developer_ips" {
  description = "List of developer public IPs to whitelist in the Azure SQL Server firewall for SSMS/VS access"
  type        = list(string)
  default     = []
}

