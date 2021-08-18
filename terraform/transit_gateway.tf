resource "aws_ec2_transit_gateway" "this" {
  description = "firewall-egress-transit-gateway"
  default_route_table_association = "enable"

    tags = {
      Name = "firewall-egress"
  }
}

## Inspection VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "inspection_vpc" {
  subnet_ids         = [module.inspection_vpc.private_subnets[0]]
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = module.inspection_vpc.vpc_id
  transit_gateway_default_route_table_association = true
  
}

# -- inspection VPC has the default route
resource "aws_ec2_transit_gateway_route" "source_vpc" {
  destination_cidr_block         = module.source_vpc.vpc_cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.source_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.this.association_default_route_table_id
}

resource "aws_ec2_transit_gateway_route" "egress_vpc" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.this.association_default_route_table_id
}

## Egress VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "egress_vpc" {
  subnet_ids         = [module.egress_vpc.private_subnets[0]]
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = module.egress_vpc.vpc_id
  transit_gateway_default_route_table_association = false
}

resource "aws_ec2_transit_gateway_route_table" "egress_vpc" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags = {
      Name = "egress_vpc"
  }
}

resource "aws_ec2_transit_gateway_route" "egress_to_firewall" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress_vpc.id
}

resource "aws_ec2_transit_gateway_route_table_association" "egress_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress_vpc.id
}


## source_vpc
resource "aws_ec2_transit_gateway_vpc_attachment" "source_vpc" {
  subnet_ids         = [module.source_vpc.private_subnets[0]]
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = module.source_vpc.vpc_id
  transit_gateway_default_route_table_association = false
}

resource "aws_ec2_transit_gateway_route_table" "source_vpc" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags = {
      Name = "source_vpce"
  }
}

resource "aws_ec2_transit_gateway_route" "source_to_firewall" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.source_vpc.id
}

resource "aws_ec2_transit_gateway_route_table_association" "source_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.source_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.source_vpc.id
}