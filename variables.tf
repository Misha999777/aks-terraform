variable "resource_group_location" {
  type        = string
  default     = "polandcentral"
  description = "Location of the resource group."
}

variable "node_type" {
  type        = string
  default     = "standard_f4s_v2"
  description = "Size of nodes in node pool."
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
