# Stand-ins for values that would normally come from elsewhere in the stack.

variable "existing_application_log_group_arn" {
  description = "ARN of a CloudWatch log group created and policy-managed outside this module"
  type        = string
  default     = "arn:aws:logs:us-east-1:000000000000:log-group:/aws/OpenSearchService/domains/example-tf-opensearch-public-prod/application-logs"
}

variable "sns_topic_arn" {
  description = "SNS topic notified by the alarms this example creates"
  type        = string
  default     = "arn:aws:sns:us-east-1:000000000000:example-alerts"
}