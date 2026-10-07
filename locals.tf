locals {
  name    = var.name != null ? var.name : var.product
  creator = "terraform"

  defaulted_tags = merge(
    var.tags,
    {
      Name                                      = local.name
      "${var.organization}:billing:product"     = var.product
      "${var.organization}:billing:environment" = var.environment
      "${var.organization}:billing:owner"       = var.owner
      creator                                   = local.creator
      repo                                      = var.repo
    }
  )

  tags = merge({ for k, v in local.defaulted_tags : k => v if lookup(data.aws_default_tags.common_tags.tags, k, "") != v })

  # Resolve which log types get a module-managed CloudWatch log group: those with
  # cloudwatch_log_group_arn left null and create_log_group left true (the default).
  managed_log_types = {
    for log_type, opts in var.log_publishing_options :
    log_type => opts if opts.cloudwatch_log_group_arn == null && opts.create_log_group
  }

  log_publishing_options = {
    for log_type, opts in var.log_publishing_options :
    log_type => opts.cloudwatch_log_group_arn != null ? opts.cloudwatch_log_group_arn : aws_cloudwatch_log_group.this[log_type].arn
  }

  create_security_group = length(var.subnet_ids) > 0 && var.create_security_group
  domain_security_group_ids = compact(concat(
    local.create_security_group ? [aws_security_group.this[0].id] : [],
    var.security_group_ids
  ))
}

data "aws_default_tags" "common_tags" {}