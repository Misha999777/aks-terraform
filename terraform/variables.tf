variable "resource_group_location" {
  type        = string
  default     = "polandcentral"
  description = "Location of the resource group."
}

variable "node_type" {
  type        = string
  default     = "standard_f4s_v2"
  description = "Type of nodes in node pool."
}

variable "nodes_min" {
  type        = string
  default     = "1"
  description = "Minimum amount of nodes in node pool."
}

variable "nodes_max" {
  type        = string
  default     = "5"
  description = "Maximum amount of nodes in node pool."
}

variable "cluster_domain_name" {
  type    = string
  description = "Domain name to use with DNS zone, will be set by workspace variables."
}

variable "cloudflare_zone" {
  type    = string
  description = "Cloudflare zone id, will be set by workspace variables."
}

variable "acme_email" {
  type    = string
  description = "Email to use with ACME, will be set by workspace variables."
}

variable "github_username" {
  type    = string
  description = "GitHub username, will be set by workspace variables."
}

variable "github_token" {
  type    = string
  description = "GitHub token, will be set by workspace variables."
}
