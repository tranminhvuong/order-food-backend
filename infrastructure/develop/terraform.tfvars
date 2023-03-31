project     = "order-food"
environment = "develop"

# VPC
vpc_id         = "vpc-09c766129c1ae7f90"
aws_account_id = "715915800849"

# Subnet
public_subnet_ids = [
  "subnet-08f6d526a5204c145",
  "subnet-04a1b10795c0b4b07",
  "subnet-011271d34de30ebed",
]
private_subnet_ids = [
  "subnet-0094ee5fe2667df00",
  "subnet-03e263fc22d7e3e16",
  "subnet-024f85c47d3ada320",
]
allow_security_group_ids = []

github_source = "https://github.com/tranminhvuong/order-food-backend.git"
