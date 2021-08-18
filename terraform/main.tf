module "source_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "source-vpc"
  cidr = "10.1.0.0/16"

  azs              = ["ap-southeast-1a"]
  private_subnets  = ["10.1.0.0/28", "10.1.1.0/24"]

  enable_nat_gateway               = false
  create_database_subnet_group     = false
  enable_dns_hostnames             = true
  enable_dns_support               = true

  create_flow_log_cloudwatch_iam_role = true
  create_flow_log_cloudwatch_log_group = true
  enable_flow_log = true
  flow_log_cloudwatch_log_group_name_prefix ="/aws/vpc-flow-log/source-vpc"
  flow_log_destination_type = "cloud-watch-logs"

}

module "inspection_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "inspection-vpc"
  cidr = "10.64.0.0/16"

  azs              = ["ap-southeast-1a"]
  private_subnets   = ["10.64.0.0/28","10.64.0.16/28"]

  enable_nat_gateway               = false
  create_database_subnet_group     = false
  enable_dns_hostnames             = true
  enable_dns_support               = true

  create_flow_log_cloudwatch_iam_role = true
  create_flow_log_cloudwatch_log_group = true
  enable_flow_log = true
  flow_log_cloudwatch_log_group_name_prefix ="/aws/vpc-flow-log/inspection-vpc"
  flow_log_destination_type = "cloud-watch-logs"

}

module "egress_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "egress-vpc"
  cidr = "10.10.0.0/16"

  azs              = ["ap-southeast-1a"]
  private_subnets  = ["10.10.0.0/28"]  # automatic route to NAT Gateway
  public_subnets   = ["10.10.1.0/24"]

  enable_nat_gateway               = true
  create_database_subnet_group     = false
  enable_dns_hostnames             = true
  enable_dns_support               = true

  create_flow_log_cloudwatch_iam_role = true
  create_flow_log_cloudwatch_log_group = true
  enable_flow_log = true
  flow_log_cloudwatch_log_group_name_prefix ="/aws/vpc-flow-log/egress-vpc"
  flow_log_destination_type = "cloud-watch-logs"

}

module "ec2" {
  source = "./ec2_linux"
  subnet_ids = [module.source_vpc.private_subnets[1]]
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
}
