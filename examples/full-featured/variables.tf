# Stand-ins for values that would normally come from elsewhere in the stack.

variable "vpc_id" {
  description = "VPC the domain and its security group are placed in"
  type        = string
  default     = "vpc-00000000000000000"
}

variable "subnet_ids" {
  description = "Private subnet ids, one per data node AZ"
  type        = list(string)
  default = [
    "subnet-00000000000000001",
    "subnet-00000000000000002",
    "subnet-00000000000000003",
  ]
}

variable "app_security_group_id" {
  description = "Security group of the application tier allowed to reach the domain"
  type        = string
  default     = "sg-00000000000000000"
}

variable "master_user_name" {
  description = "Master username for the domain's internal user database"
  type        = string
  default     = "opensearch-admin"
}

variable "master_user_password" {
  description = "Master password for the domain's internal user database"
  type        = string
  default     = "Replace-Me-Before-Applying-1!"
  sensitive   = true
}

variable "custom_endpoint" {
  description = "Custom hostname for the domain endpoint"
  type        = string
  default     = "search.example.pbs.org"
}

variable "custom_endpoint_certificate_arn" {
  description = "ACM certificate ARN covering custom_endpoint"
  type        = string
  default     = "arn:aws:acm:us-east-1:000000000000:certificate/00000000-0000-0000-0000-000000000000"
}

variable "sns_topic_arn" {
  description = "SNS topic notified by the alarms this example creates"
  type        = string
  default     = "arn:aws:sns:us-east-1:000000000000:example-alerts"
}