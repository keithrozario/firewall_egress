resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.source_vpc.vpc_id

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_ssm_parameter" "lambda_security_group" {
  name  = "/serverless/lambda_security_group"
  type  = "String"
  value = aws_security_group.allow_tls.id
}

resource "aws_ssm_parameter" "lambda_subnet" {
  name  = "/serverless/lambda_subnet"
  type  = "String"
  value = module.source_vpc.private_subnets[1]
}