output "domain_id" {
  description = "Id of the OpenSearch domain"
  value       = aws_opensearch_domain.this.domain_id
}

output "domain_arn" {
  description = "ARN of the OpenSearch domain"
  value       = aws_opensearch_domain.this.arn
}

output "domain_name" {
  description = "Name of the OpenSearch domain"
  value       = aws_opensearch_domain.this.domain_name
}

output "endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = aws_opensearch_domain.this.endpoint
}

output "dashboard_endpoint" {
  description = "Domain-specific endpoint for OpenSearch Dashboards"
  value       = aws_opensearch_domain.this.dashboard_endpoint
}

output "kibana_endpoint" {
  description = "Deprecated alias of dashboard_endpoint, kept for callers migrating from aws_elasticsearch_domain"
  value       = aws_opensearch_domain.this.dashboard_endpoint
}

output "security_group_id" {
  description = "Id of the security group this module created, or null when create_security_group is false or the domain is public"
  value       = local.create_security_group ? aws_security_group.this[0].id : null
}

output "log_group_arns" {
  description = "Map of log type to the ARN of the CloudWatch log group this module created for it"
  value       = { for log_type, group in aws_cloudwatch_log_group.this : log_type => group.arn }
}