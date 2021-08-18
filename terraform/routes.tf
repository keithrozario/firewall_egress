# Spoke VPC
## TGW Subnet
resource "aws_route" "tgw_eni" {
  route_table_id            = module.source_vpc.private_route_table_ids[0]
  destination_cidr_block    = "0.0.0.0/0"
  transit_gateway_id = aws_ec2_transit_gateway.this.id
}
## EC2 Subnet
resource "aws_route" "ec2" {
  route_table_id            = module.source_vpc.private_route_table_ids[1]
  destination_cidr_block    = "0.0.0.0/0"
  transit_gateway_id = aws_ec2_transit_gateway.this.id
}

# Inspection VPC
## TGW Subnet
resource "aws_route" "to_firewall" {
  route_table_id = module.inspection_vpc.private_route_table_ids[0]
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id = aws_networkfirewall_firewall.this.*.firewall_status[0].*.sync_states[0].*.attachment[0].0.endpoint_id
}
## Firewall Subnet
resource "aws_route" "from_firewall" {
  route_table_id = module.inspection_vpc.private_route_table_ids[1]
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id = aws_ec2_transit_gateway.this.id
}


# Egress VPC
## TGW Subnet
resource "aws_route" "from_source_vpc" {
  route_table_id            = module.egress_vpc.private_route_table_ids[0]
  destination_cidr_block    = module.source_vpc.vpc_cidr_block
  transit_gateway_id = aws_ec2_transit_gateway.this.id
}

## Public Subnet
resource "aws_route" "to_source_vpc" {
  route_table_id            = module.egress_vpc.public_route_table_ids[0]
  destination_cidr_block    = module.source_vpc.vpc_cidr_block
  transit_gateway_id = aws_ec2_transit_gateway.this.id
}