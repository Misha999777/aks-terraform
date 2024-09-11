variable "organization_name" {
  type    = string
  description = "TFC organization name, will be set by workspace variables."
}

variable "workspace_name" {
  type    = string
  description = "TFC workspace name, will be set by workspace variables."
}

variable "github_username" {
  type    = string
  description = "GitHub username, will be set by workspace variables."
}

variable "github_password" {
  type    = string
  description = "GitHub token, will be set by workspace variables."
}
