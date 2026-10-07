resource "aws_cloudwatch_log_group" "this" {
  for_each = local.managed_log_types

  name              = "/aws/opensearch/domains/${local.name}/${lower(replace(each.key, "_", "-"))}"
  retention_in_days = each.value.retention_in_days
  tags              = local.tags
}

resource "aws_cloudwatch_log_resource_policy" "this" {
  count = length(local.managed_log_types) > 0 ? 1 : 0

  policy_name = "${local.name}-opensearch-logs"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "es.amazonaws.com" }
        Action = [
          "logs:PutLogEvents",
          "logs:PutLogEventsBatch",
          "logs:CreateLogStream",
        ]
        Resource = [for log_type in keys(local.managed_log_types) : "${aws_cloudwatch_log_group.this[log_type].arn}:*"]
      },
    ]
  })
}

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  name        = "${local.name}-opensearch"
  description = "Access to the ${local.name} OpenSearch domain"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = length(ingress.value.cidr_blocks) > 0 ? ingress.value.cidr_blocks : null
      security_groups = length(ingress.value.security_group_ids) > 0 ? ingress.value.security_group_ids : null
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.egress_cidr_blocks
  }

  tags = local.tags
}

resource "aws_opensearch_domain" "this" {
  domain_name    = local.name
  engine_version = var.engine_version

  cluster_config {
    instance_type                 = var.instance_type
    instance_count                = var.instance_count
    dedicated_master_enabled      = var.dedicated_master_enabled
    dedicated_master_type         = var.dedicated_master_enabled ? var.dedicated_master_type : null
    dedicated_master_count        = var.dedicated_master_enabled ? var.dedicated_master_count : null
    zone_awareness_enabled        = var.zone_awareness_enabled
    multi_az_with_standby_enabled = var.multi_az_with_standby_enabled
    warm_enabled                  = var.warm_enabled
    warm_type                     = var.warm_enabled ? var.warm_type : null
    warm_count                    = var.warm_enabled ? var.warm_count : null

    dynamic "cold_storage_options" {
      for_each = var.warm_enabled ? [1] : []
      content {
        enabled = var.cold_storage_enabled
      }
    }

    dynamic "zone_awareness_config" {
      for_each = var.zone_awareness_enabled ? [1] : []
      content {
        availability_zone_count = var.availability_zone_count
      }
    }
  }

  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_type = var.ebs_enabled ? var.volume_type : null
    volume_size = var.ebs_enabled ? var.volume_size : null
    iops        = var.ebs_enabled ? var.iops : null
    throughput  = var.ebs_enabled && var.volume_type == "gp3" ? var.throughput : null
  }

  dynamic "vpc_options" {
    for_each = length(var.subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = local.domain_security_group_ids
    }
  }

  encrypt_at_rest {
    enabled    = var.encrypt_at_rest_enabled
    kms_key_id = var.encrypt_at_rest_enabled ? var.kms_key_id : null
  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption_enabled
  }

  domain_endpoint_options {
    enforce_https                   = var.enforce_https
    tls_security_policy             = var.enforce_https ? var.tls_security_policy : null
    custom_endpoint_enabled         = var.custom_endpoint_enabled
    custom_endpoint                 = var.custom_endpoint_enabled ? var.custom_endpoint : null
    custom_endpoint_certificate_arn = var.custom_endpoint_enabled ? var.custom_endpoint_certificate_arn : null
  }

  dynamic "advanced_security_options" {
    for_each = var.advanced_security_options_enabled ? [1] : []
    content {
      enabled                        = true
      internal_user_database_enabled = var.internal_user_database_enabled

      master_user_options {
        master_user_arn      = var.internal_user_database_enabled ? null : var.master_user_arn
        master_user_name     = var.internal_user_database_enabled ? var.master_user_name : null
        master_user_password = var.internal_user_database_enabled ? var.master_user_password : null
      }
    }
  }

  dynamic "auto_tune_options" {
    for_each = var.auto_tune_enabled ? [1] : []
    content {
      desired_state       = "ENABLED"
      rollback_on_disable = var.auto_tune_rollback_on_disable
      use_off_peak_window = var.off_peak_window_enabled
    }
  }

  off_peak_window_options {
    enabled = var.off_peak_window_enabled

    dynamic "off_peak_window" {
      for_each = var.off_peak_window_enabled ? [1] : []
      content {
        window_start_time {
          hours   = var.off_peak_window_start_hour
          minutes = var.off_peak_window_start_minute
        }
      }
    }
  }

  software_update_options {
    auto_software_update_enabled = var.software_update_auto_update_enabled
  }

  dynamic "snapshot_options" {
    for_each = var.automated_snapshot_start_hour != null ? [1] : []
    content {
      automated_snapshot_start_hour = var.automated_snapshot_start_hour
    }
  }

  dynamic "log_publishing_options" {
    for_each = local.log_publishing_options
    content {
      log_type                 = log_publishing_options.key
      cloudwatch_log_group_arn = log_publishing_options.value
    }
  }

  tags = local.tags

  depends_on = [aws_cloudwatch_log_resource_policy.this]
}

resource "aws_opensearch_domain_policy" "this" {
  count = var.access_policies != null ? 1 : 0

  domain_name     = aws_opensearch_domain.this.domain_name
  access_policies = var.access_policies
}

# --- CloudWatch alarms -------------------------------------------------------------------------

data "aws_caller_identity" "current" {
  count = var.create_cloudwatch_alarms ? 1 : 0
}

resource "aws_cloudwatch_metric_alarm" "cluster_status_red" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.name}-opensearch-cluster-status-red"
  alarm_description   = "OpenSearch domain ${local.name} cluster status is red: one or more primary shards are unassigned"
  namespace           = "AWS/ES"
  metric_name         = "ClusterStatus.red"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  evaluation_periods  = 1
  period              = 60
  statistic           = "Maximum"
  treat_missing_data  = "breaching"
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions

  dimensions = {
    DomainName = aws_opensearch_domain.this.domain_name
    ClientId   = data.aws_caller_identity.current[0].account_id
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "cluster_status_yellow" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.name}-opensearch-cluster-status-yellow"
  alarm_description   = "OpenSearch domain ${local.name} cluster status is yellow: one or more replica shards are unassigned"
  namespace           = "AWS/ES"
  metric_name         = "ClusterStatus.yellow"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  evaluation_periods  = 1
  period              = 60
  statistic           = "Maximum"
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions

  dimensions = {
    DomainName = aws_opensearch_domain.this.domain_name
    ClientId   = data.aws_caller_identity.current[0].account_id
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.name}-opensearch-free-storage-space"
  alarm_description   = "OpenSearch domain ${local.name} has less than ${var.alarm_free_storage_space_minimum_mb}MB of free storage on its least-free data node"
  namespace           = "AWS/ES"
  metric_name         = "FreeStorageSpace"
  comparison_operator = "LessThanThreshold"
  threshold           = var.alarm_free_storage_space_minimum_mb
  evaluation_periods  = 1
  period              = 60
  statistic           = "Minimum"
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions

  dimensions = {
    DomainName = aws_opensearch_domain.this.domain_name
    ClientId   = data.aws_caller_identity.current[0].account_id
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "cluster_index_writes_blocked" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.name}-opensearch-index-writes-blocked"
  alarm_description   = "OpenSearch domain ${local.name} is blocking index writes, usually due to low disk space"
  namespace           = "AWS/ES"
  metric_name         = "ClusterIndexWritesBlocked"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  evaluation_periods  = 1
  period              = 300
  statistic           = "Maximum"
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions

  dimensions = {
    DomainName = aws_opensearch_domain.this.domain_name
    ClientId   = data.aws_caller_identity.current[0].account_id
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "node_jvm_memory_pressure" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.name}-opensearch-node-jvm-memory-pressure"
  alarm_description   = "OpenSearch domain ${local.name} data node JVM memory pressure is above ${var.alarm_jvm_memory_pressure_maximum_percent}%"
  namespace           = "AWS/ES"
  metric_name         = "JVMMemoryPressure"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.alarm_jvm_memory_pressure_maximum_percent
  evaluation_periods  = 1
  period              = 60
  statistic           = "Average"
  treat_missing_data  = "breaching"
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions

  dimensions = {
    DomainName = aws_opensearch_domain.this.domain_name
    ClientId   = data.aws_caller_identity.current[0].account_id
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "master_jvm_memory_pressure" {
  count = var.create_cloudwatch_alarms && var.dedicated_master_enabled ? 1 : 0

  alarm_name          = "${local.name}-opensearch-master-jvm-memory-pressure"
  alarm_description   = "OpenSearch domain ${local.name} master node JVM memory pressure is above ${var.alarm_jvm_memory_pressure_maximum_percent}%"
  namespace           = "AWS/ES"
  metric_name         = "MasterJVMMemoryPressure"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.alarm_jvm_memory_pressure_maximum_percent
  evaluation_periods  = 1
  period              = 60
  statistic           = "Average"
  treat_missing_data  = "breaching"
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions

  dimensions = {
    DomainName = aws_opensearch_domain.this.domain_name
    ClientId   = data.aws_caller_identity.current[0].account_id
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.name}-opensearch-cpu-utilization"
  alarm_description   = "OpenSearch domain ${local.name} node CPU utilization is above ${var.alarm_cpu_utilization_maximum_percent}%"
  namespace           = "AWS/ES"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.alarm_cpu_utilization_maximum_percent
  evaluation_periods  = 3
  period              = 60
  statistic           = "Average"
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions

  dimensions = {
    DomainName = aws_opensearch_domain.this.domain_name
    ClientId   = data.aws_caller_identity.current[0].account_id
  }

  tags = local.tags
}