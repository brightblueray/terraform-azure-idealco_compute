# General variables
variable "location" {
  type        = string
  description = "The Azure Region in which all resources in this example should be created."
  default     = "eastus2"
}

variable "prefix" {
  type        = string
  description = "prefix for searching AWS console"
  default     = "rryjewski"
}

variable "rg" {
  # default =  "rryjewski-brief-gorilla-rg"
}

variable "subnet_id" {
  # default = "/subscriptions/14692f20-9428-451b-8298-102ed4e39c2a/resourceGroups/rryjewski-brief-gorilla-rg/providers/Microsoft.Network/virtualNetworks/rryjewski-brief-gorilla-network/subnets/internal"
}

variable "azure_size" {
    default = "Standard_A1_v2"
}