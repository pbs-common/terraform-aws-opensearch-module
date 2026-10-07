# Mirrors an ECS application that reaches OpenSearch only from inside the VPC: a single subnet,
# a security group opened to the application's own security group, and a wide-open access policy
# whose real restriction is "which security group can reach the domain's network interface" rather
# than "which IAM principal signed the request".

module "opensearch" {
  source = "../.."

  # Tagging Parameters
  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo

  # Optional Parameters
  subnet_ids = [var.subnet_ids[0]]
  vpc_id     = var.vpc_id

  instance_type  = "r6g.large.search"
  instance_count = 2

  ingress_rules = [
    {
      description        = "Application tier"
      security_group_ids = [var.app_security_group_id]
    },
  ]

  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "*" }
        Action    = "es:*"
        Resource  = "arn:aws:es:us-east-1:${data.aws_caller_identity.current.account_id}:domain/${var.product}/*"
      },
    ]
  })

  # Index slow logs on all the time; application logs only where it's worth the noise.
  log_publishing_options = {
    INDEX_SLOW_LOGS = {}
    ES_APPLICATION_LOGS = {
      retention_in_days = var.environment == "prod" ? 90 : 30
    }
  }

  create_cloudwatch_alarms = true
  alarm_actions            = [var.sns_topic_arn]
  ok_actions               = [var.sns_topic_arn]
}