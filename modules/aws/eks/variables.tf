#-----------------------------------------------------------------------------------------------------------------------
# Variables
#-----------------------------------------------------------------------------------------------------------------------
variable "name" {
  default     = "my-eks"
  type        = string
  description = "Name of the VPC to create"
}

variable "subnet_ids" {
  default = []
  type = list(string)
  description = "Subnet IDs which should be attached to the EKS cluster"
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Minimum number of subnets should be 2"
  }
}

variable "tags" {
  description = "Map of tags block"
  type = map(string)
  default = {}
}
