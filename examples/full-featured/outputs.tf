output "domain_id" {
  description = "Id of the OpenSearch domain"
  value       = module.opensearch.domain_id
}

output "domain_arn" {
  description = "ARN of the OpenSearch domain"
  value       = module.opensearch.domain_arn
}

output "endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = module.opensearch.endpoint
}

output "dashboard_endpoint" {
  description = "Domain-specific endpoint for OpenSearch Dashboards"
  value       = module.opensearch.dashboard_endpoint
}

output "security_group_id" {
  description = "Id of the security group this module created for the domain"
  value       = module.opensearch.security_group_id
}

output "log_group_arns" {
  description = "ARNs of the CloudWatch log groups this module created"
  value       = module.opensearch.log_group_arns
}