#-----------------------------------------------------------------------------------------------------------------------
# Variables
#-----------------------------------------------------------------------------------------------------------------------
variable "name" {
  default     = "my-vpc"
  type        = string
  description = "Name of the VPC to create"
}

variable "vpc_cidr" {
  description = "CIDR of the VPC to create"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "List of private subnets"
  type = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "public_subnets" {
  description = "List of public subnets"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateway"
  type = bool
  default = true
}

variable "tags" {
  description = "Map of tags block"
  type = map(string)
  default = {}
}
