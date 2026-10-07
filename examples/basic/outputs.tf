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