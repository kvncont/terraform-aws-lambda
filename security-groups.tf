resource "aws_security_group" "lambda" {
  count = var.vpc_config == null ? 0 : (var.vpc_config.create_security_group ? 1 : 0)

  name_prefix = "${var.function_name}-"
  description = "Network access for ${var.function_name} Lambda"
  vpc_id      = var.vpc_config.vpc_id
  tags        = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "lambda" {
  for_each = (var.vpc_config == null ? false : var.vpc_config.create_security_group) ? var.security_group_ingress_rules : {}

  security_group_id = aws_security_group.lambda[0].id
  description       = each.value.description
  ip_protocol       = each.value.protocol
  from_port         = each.value.protocol == "-1" ? null : each.value.from_port
  to_port           = each.value.protocol == "-1" ? null : each.value.to_port
  cidr_ipv4         = each.value.cidr_ipv4
  tags              = var.tags
}

resource "aws_vpc_security_group_egress_rule" "lambda" {
  for_each = (var.vpc_config == null ? false : var.vpc_config.create_security_group) ? var.security_group_egress_rules : {}

  security_group_id = aws_security_group.lambda[0].id
  description       = each.value.description
  ip_protocol       = each.value.protocol
  from_port         = each.value.protocol == "-1" ? null : each.value.from_port
  to_port           = each.value.protocol == "-1" ? null : each.value.to_port
  cidr_ipv4         = each.value.cidr_ipv4
  tags              = var.tags
}