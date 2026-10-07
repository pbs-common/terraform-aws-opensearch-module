# Demonstrates the less-common, larger-scale features this module supports: dedicated masters,
# UltraWarm + cold storage for tiered retention, fine-grained access control with an internal
# master user, a custom domain name, every log type, and the full set of CloudWatch alarms.

module "opensearch" {
  source = "../.."

  # Tagging Parameters
  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo

  # Optional Parameters
  subnet_ids = var.subnet_ids
  vpc_id     = var.vpc_id

  ingress_rules = [
    {
      description        = "Application tier"
      security_group_ids = [var.app_security_group_id]
    },
  ]

  instance_type            = "r6g.xlarge.search"
  instance_count           = 3
  dedicated_master_enabled = true
  dedicated_master_type    = "m6g.large.search"
  dedicated_master_count   = 3

  zone_awareness_enabled  = true
  availability_zone_count = 3

  warm_enabled         = true
  warm_type            = "ultrawarm1.medium.search"
  warm_count           = 2
  cold_storage_enabled = true

  volume_type = "gp3"
  volume_size = 200
  throughput  = 250

  advanced_security_options_enabled = true
  internal_user_database_enabled    = true
  master_user_name                  = var.master_user_name
  master_user_password              = var.master_user_password

  custom_endpoint_enabled         = true
  custom_endpoint                 = var.custom_endpoint
  custom_endpoint_certificate_arn = var.custom_endpoint_certificate_arn

  log_publishing_options = {
    INDEX_SLOW_LOGS     = {}
    SEARCH_SLOW_LOGS    = {}
    ES_APPLICATION_LOGS = {}
    AUDIT_LOGS          = {}
  }

  create_cloudwatch_alarms = true
  alarm_actions            = [var.sns_topic_arn]
  ok_actions               = [var.sns_topic_arn]
}