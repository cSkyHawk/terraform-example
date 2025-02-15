#-----------------------------------------------------------------------------------------------------------------------
# Outputs
#-----------------------------------------------------------------------------------------------------------------------
output "ingress_address" {
  value = format("http://%s", module.eks.ingress_address)
  description = "Publicly available ALB endpoint"
}
