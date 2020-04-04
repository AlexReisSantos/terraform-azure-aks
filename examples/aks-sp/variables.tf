
variable "prefix" {
  default = "terraform-aks-ci"
}

variable "admin_username" {
  default = "terraform-aks-ci"
}

variable "auto_scaling_default_node" {
  default = false
}

variable "node_count" {
  default = 1
}

variable "node_max_count" {
  default = null
}

variable "node_min_count" {
  default = null
}

variable "storage_account_name" {
  default = "terraformstci"
}

variable "tags" {
  default = {
     "MAINTAINER" = "Azure Devops CI"
  }
}