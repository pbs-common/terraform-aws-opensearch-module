# Mirrors a service that keeps its OpenSearch domain outside any VPC and relies on IAM request
# signing for access control instead of a resource policy: access_policies is left null, so this
# module does not manage an aws_opensearch_domain_policy, and callers reach the domain by signing
# requests with an IAM role/user whose own identity policy allows es:ESHttp*.
#
# application-logs also come from a log group that already exists and is already granted the
# es.amazonaws.com log-write permission elsewhere, so create_log_group is not used here -- the
# module simply points log_publishing_options at it.

module "opensearch" {
  source = "../.."

  # Tagging Parameters
  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo

  # Optional Parameters
  engine_version = "OpenSearch_2.19"
  instance_type  = "r7g.2xlarge.search"
  instance_count = var.environment == "prod" ? 3 : 1

  zone_awareness_enabled        = var.environment == "prod"
  availability_zone_count       = 3
  multi_az_with_standby_enabled = var.environment == "prod"

  volume_size = 100

  log_publishing_options = {
    ES_APPLICATION_LOGS = {
      cloudwatch_log_group_arn = var.existing_application_log_group_arn
    }
  }

  create_cloudwatch_alarms = true
  alarm_actions            = [var.sns_topic_arn]
  ok_actions               = [var.sns_topic_arn]
}