resource "aws_networkfirewall_rule_group" "useless_rule" {
  capacity = 100
  name     = "uselessRule"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              source {
                address_definition = "192.168.0.0/24"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_networkfirewall_rule_group" "allow_domains" {
  capacity = 200
  name     = "allowDomains"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [module.source_vpc.vpc_cidr_block]
        }
      }
    }
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["TLS_SNI", "HTTP_HOST"]
        targets              = [
            "ssm.ap-southeast-1.amazonaws.com",
            "ssmmessages.ap-southeast-1.amazonaws.com",
            "ec2messages.ap-southeast-1.amazonaws.com",
            ".amazonaws.com",
            ".keithrozario.com",
            ".google.com"
        ]
      }
    }
  }
}


resource "aws_networkfirewall_firewall_policy" "this" {
  name = "firewallPolicy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.useless_rule.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.allow_domains.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.drop_icmp_cloudflare.arn
    }
  }
}

resource "aws_networkfirewall_rule_group" "block_everything_from_source" {
  capacity = 300
  name     = "blockEverythingSource"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      stateful_rule {
        action = "DROP"
        header {
          destination      = "0.0.0.0/0"
          destination_port = "ANY"
          direction        = "ANY"
          protocol         = "TLS"
          source           = module.source_vpc.vpc_cidr_block
          source_port      = "ANY"
        }
        rule_option {
          keyword = "sid:1"
        }
      }
    }
  }
}

resource "aws_networkfirewall_rule_group" "drop_icmp_cloudflare" {
  capacity = 100
  name     = "dropICMPCloudflare"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      stateful_rule {
        action = "DROP"
        header {
          destination      = "1.1.1.1/32"
          destination_port = "ANY"
          direction        = "ANY"
          protocol         = "ICMP"
          source           = module.source_vpc.vpc_cidr_block
          source_port      = "ANY"
        }
        rule_option {
          keyword = "sid:2"
        }
      }
    }
  }
}

resource "aws_networkfirewall_firewall" "this" {
  name                = "AWSNetworkFirewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.this.arn
  vpc_id              = module.inspection_vpc.vpc_id
  subnet_mapping {
    subnet_id = module.inspection_vpc.private_subnets[1]
  }
}