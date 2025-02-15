#-----------------------------------------------------------------------------------------------------------------------
# VPC Module
#-----------------------------------------------------------------------------------------------------------------------
module "vpc" {
  source = "./modules/aws/vpc"

  name     = var.vpc_name
  vpc_cidr = var.vpc_cidr

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  availability_zones = var.availability_zones
  enable_nat_gateway = var.enable_nat_gateway

  tags = var.tags
}


#-----------------------------------------------------------------------------------------------------------------------
# EKS Module
#-----------------------------------------------------------------------------------------------------------------------
module "eks" {
  source = "./modules/aws/eks"

  name       = var.eks_name
  subnet_ids = module.vpc.private_subnets_ids
}
