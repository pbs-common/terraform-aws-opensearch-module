# Stand-ins for values that would normally come from the shared VPC / application stack.

variable "vpc_id" {
  description = "VPC the domain and its security group are placed in"
  type        = string
  default     = "vpc-00000000000000000"
}

variable "subnet_ids" {
  description = "Private subnet ids, one per data node AZ"
  type        = list(string)
  default     = ["subnet-00000000000000001", "subnet-00000000000000002"]
}

variable "app_security_group_id" {
  description = "Security group of the application tier (e.g. the ECS service) allowed to reach the domain"
  type        = string
  default     = "sg-00000000000000000"
}

variable "sns_topic_arn" {
  description = "SNS topic notified by the alarms this example creates"
  type        = string
  default     = "arn:aws:sns:us-east-1:000000000000:example-alerts"
}