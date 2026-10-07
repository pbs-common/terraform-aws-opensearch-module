variable "name" {
  description = "(optional) Name of the OpenSearch domain (defaults to product if null)"
  default     = null
  type        = string
}

# --- Cluster config --------------------------------------------------------------------------

variable "engine_version" {
  description = "(optional) Engine version, e.g. OpenSearch_2.19 or Elasticsearch_7.10"
  default     = "OpenSearch_2.19"
  type        = string
  validation {
    condition     = can(regex("^(OpenSearch|Elasticsearch)_[0-9]+\\.[0-9]+$", var.engine_version))
    error_message = "The engine_version variable must look like OpenSearch_2.19 or Elasticsearch_7.10."
  }
}

variable "instance_type" {
  description = "(optional) Instance type for data nodes"
  default     = "t3.small.search"
  type        = string
}

variable "instance_count" {
  description = "(optional) Number of data nodes"
  default     = 1
  type        = number
}

variable "dedicated_master_enabled" {
  description = "(optional) Whether to use dedicated master nodes"
  default     = false
  type        = bool
}

variable "dedicated_master_type" {
  description = "(optional) Instance type for dedicated master nodes (only used when dedicated_master_enabled is true)"
  default     = "t3.small.search"
  type        = string
}

variable "dedicated_master_count" {
  description = "(optional) Number of dedicated master nodes (only used when dedicated_master_enabled is true); AWS requires 3 or 5"
  default     = 3
  type        = number
  validation {
    condition     = contains([3, 5], var.dedicated_master_count)
    error_message = "The dedicated_master_count variable must be 3 or 5."
  }
}

variable "zone_awareness_enabled" {
  description = "(optional) Whether to spread data nodes across multiple availability zones"
  default     = false
  type        = bool
}

variable "availability_zone_count" {
  description = "(optional) Number of availability zones used when zone_awareness_enabled is true"
  default     = 2
  type        = number
  validation {
    condition     = contains([2, 3], var.availability_zone_count)
    error_message = "The availability_zone_count variable must be 2 or 3."
  }
}

variable "multi_az_with_standby_enabled" {
  description = "(optional) Whether to deploy a standby availability zone for faster failover (requires zone_awareness_enabled)"
  default     = false
  type        = bool
}

variable "warm_enabled" {
  description = "(optional) Whether to enable UltraWarm nodes for infrequently-accessed data"
  default     = false
  type        = bool
}

variable "warm_type" {
  description = "(optional) Instance type for UltraWarm nodes (only used when warm_enabled is true)"
  default     = "ultrawarm1.medium.search"
  type        = string
}

variable "warm_count" {
  description = "(optional) Number of UltraWarm nodes (only used when warm_enabled is true)"
  default     = 2
  type        = number
}

variable "cold_storage_enabled" {
  description = "(optional) Whether to enable cold storage (requires warm_enabled)"
  default     = false
  type        = bool
}

# --- EBS storage -------------------------------------------------------------------------------

variable "ebs_enabled" {
  description = "(optional) Whether data nodes use EBS storage instead of instance store"
  default     = true
  type        = bool
}

variable "volume_type" {
  description = "(optional) EBS volume type"
  default     = "gp3"
  type        = string
  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.volume_type)
    error_message = "The volume_type variable must be one of [gp2, gp3, io1, io2]."
  }
}

variable "volume_size" {
  description = "(optional) EBS volume size in GiB per data node"
  default     = 20
  type        = number
}

variable "iops" {
  description = "(optional) Baseline IOPS for gp3/io1/io2 volumes (defaults to the EBS volume type's own default when null)"
  default     = null
  type        = number
}

variable "throughput" {
  description = "(optional) Throughput in MiB/s for gp3 volumes (defaults to the EBS volume type's own default when null)"
  default     = null
  type        = number
}

# --- Networking ----------------------------------------------------------------------------

variable "subnet_ids" {
  description = "(optional) Subnet ids to place the domain in. One subnet per availability zone used; leave empty to create a public (non-VPC) domain"
  default     = []
  type        = list(string)
}

variable "vpc_id" {
  description = "(optional) VPC id the security group this module creates is placed in. Required when subnet_ids is set and create_security_group is true."
  default     = null
  type        = string
  validation {
    condition     = !(length(var.subnet_ids) > 0 && var.create_security_group) || var.vpc_id != null
    error_message = "The vpc_id variable is required when subnet_ids is set and create_security_group is true."
  }
}

variable "create_security_group" {
  description = "(optional) Whether to create a security group for the domain when subnet_ids is set"
  default     = true
  type        = bool
}

variable "security_group_ids" {
  description = "(optional) Extra security group ids to attach to the domain, in addition to the one this module creates. Required if create_security_group is false and subnet_ids is set."
  default     = []
  type        = list(string)
}

variable "ingress_rules" {
  description = "(optional) Ingress rules added to the security group this module creates. Each rule allows either cidr_blocks or security_group_ids (or both)."
  default     = []
  type = list(object({
    description        = optional(string)
    from_port          = optional(number, 443)
    to_port            = optional(number, 443)
    protocol           = optional(string, "tcp")
    cidr_blocks        = optional(list(string), [])
    security_group_ids = optional(list(string), [])
  }))
}

variable "egress_cidr_blocks" {
  description = "(optional) CIDR blocks allowed on all outbound traffic from the security group this module creates"
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

# --- Access policy ---------------------------------------------------------------------------

variable "access_policies" {
  description = "(optional) Raw JSON access policy document for the domain. Leave null to manage access purely through the security group (VPC domains) or through IAM request signing (public domains)."
  default     = null
  type        = string
}

# --- Encryption and transport ------------------------------------------------------------------

variable "encrypt_at_rest_enabled" {
  description = "(optional) Whether to encrypt data at rest"
  default     = true
  type        = bool
}

variable "kms_key_id" {
  description = "(optional) KMS key id/ARN used for encryption at rest (defaults to the AWS-owned key when null)"
  default     = null
  type        = string
}

variable "node_to_node_encryption_enabled" {
  description = "(optional) Whether to encrypt traffic between nodes"
  default     = true
  type        = bool
}

variable "enforce_https" {
  description = "(optional) Whether to require HTTPS for all traffic to the domain endpoint"
  default     = true
  type        = bool
}

variable "tls_security_policy" {
  description = "(optional) Minimum TLS version / cipher policy for the domain endpoint"
  default     = "Policy-Min-TLS-1-2-PFS-2023-10"
  type        = string
}

variable "custom_endpoint_enabled" {
  description = "(optional) Whether to serve the domain on a custom hostname"
  default     = false
  type        = bool
}

variable "custom_endpoint" {
  description = "(optional) Custom hostname for the domain endpoint (required when custom_endpoint_enabled is true)"
  default     = null
  type        = string
}

variable "custom_endpoint_certificate_arn" {
  description = "(optional) ACM certificate ARN for the custom endpoint (required when custom_endpoint_enabled is true)"
  default     = null
  type        = string
}

# --- Fine-grained access control -----------------------------------------------------------

variable "advanced_security_options_enabled" {
  description = "(optional) Whether to enable fine-grained access control. Requires encrypt_at_rest_enabled, node_to_node_encryption_enabled and enforce_https to all be true."
  default     = false
  type        = bool
}

variable "internal_user_database_enabled" {
  description = "(optional) Whether to use the built-in user database for fine-grained access control instead of an IAM master user"
  default     = true
  type        = bool
}

variable "master_user_arn" {
  description = "(optional) IAM ARN of the master user for fine-grained access control (used instead of master_user_name/master_user_password when internal_user_database_enabled is false)"
  default     = null
  type        = string
}

variable "master_user_name" {
  description = "(optional) Master username for the internal user database (used when internal_user_database_enabled is true)"
  default     = null
  type        = string
}

variable "master_user_password" {
  description = "(optional) Master password for the internal user database (used when internal_user_database_enabled is true)"
  default     = null
  type        = string
  sensitive   = true
}

# --- Logging ---------------------------------------------------------------------------------

variable "log_publishing_options" {
  description = "(optional) Map of OpenSearch log types to publish to CloudWatch Logs. Keys must be one of INDEX_SLOW_LOGS, SEARCH_SLOW_LOGS, ES_APPLICATION_LOGS or AUDIT_LOGS. When cloudwatch_log_group_arn is left null and create_log_group is left true (the defaults), the module creates and manages that log group, plus the CloudWatch resource policy letting the OpenSearch service write to it. Set cloudwatch_log_group_arn to point at a log group managed elsewhere instead."
  default     = {}
  type = map(object({
    cloudwatch_log_group_arn = optional(string)
    create_log_group         = optional(bool, true)
    retention_in_days        = optional(number, 30)
  }))
  validation {
    condition     = alltrue([for k in keys(var.log_publishing_options) : contains(["INDEX_SLOW_LOGS", "SEARCH_SLOW_LOGS", "ES_APPLICATION_LOGS", "AUDIT_LOGS"], k)])
    error_message = "The log_publishing_options keys must be one of [INDEX_SLOW_LOGS, SEARCH_SLOW_LOGS, ES_APPLICATION_LOGS, AUDIT_LOGS]."
  }
}

# --- Snapshots (legacy Elasticsearch < 5.3 only; ignored by modern OpenSearch domains) --------

variable "automated_snapshot_start_hour" {
  description = "(optional) UTC hour at which automated daily snapshots are taken. Only meaningful for legacy Elasticsearch domains without encrypt_at_rest_enabled; modern OpenSearch domains manage snapshots automatically. Leave null to omit the block."
  default     = null
  type        = number
}

# --- Auto-Tune and maintenance windows ----------------------------------------------------------

variable "auto_tune_enabled" {
  description = "(optional) Whether to enable Auto-Tune performance recommendations"
  default     = false
  type        = bool
}

variable "auto_tune_rollback_on_disable" {
  description = "(optional) Whether to roll back Auto-Tune changes when Auto-Tune is disabled"
  default     = "NO_ROLLBACK"
  type        = string
  validation {
    condition     = contains(["NO_ROLLBACK", "DEFAULT_ROLLBACK"], var.auto_tune_rollback_on_disable)
    error_message = "The auto_tune_rollback_on_disable variable must be one of [NO_ROLLBACK, DEFAULT_ROLLBACK]."
  }
}

variable "off_peak_window_enabled" {
  description = "(optional) Whether to restrict Auto-Tune and other maintenance actions to an off-peak window"
  default     = true
  type        = bool
}

variable "off_peak_window_start_hour" {
  description = "(optional) UTC hour the off-peak maintenance window starts"
  default     = 2
  type        = number
}

variable "off_peak_window_start_minute" {
  description = "(optional) Minute of the hour the off-peak maintenance window starts"
  default     = 0
  type        = number
}

variable "software_update_auto_update_enabled" {
  description = "(optional) Whether to automatically apply service software updates during the off-peak window"
  default     = true
  type        = bool
}

# --- CloudWatch alarms -------------------------------------------------------------------------

variable "create_cloudwatch_alarms" {
  description = "(optional) Whether to create the common set of CloudWatch alarms for this domain (cluster status, free storage, JVM memory pressure, CPU utilization)"
  default     = false
  type        = bool
}

variable "alarm_actions" {
  description = "(optional) ARNs (e.g. SNS topics) notified when an alarm created by create_cloudwatch_alarms transitions into ALARM"
  default     = []
  type        = list(string)
}

variable "ok_actions" {
  description = "(optional) ARNs (e.g. SNS topics) notified when an alarm created by create_cloudwatch_alarms transitions back to OK"
  default     = []
  type        = list(string)
}

variable "alarm_free_storage_space_minimum_mb" {
  description = "(optional) Alarm when the least-free data node has fewer than this many megabytes of free storage left"
  default     = 10240
  type        = number
}

variable "alarm_jvm_memory_pressure_maximum_percent" {
  description = "(optional) Alarm when node (and, with dedicated_master_enabled, master) JVM memory pressure exceeds this percentage"
  default     = 80
  type        = number
}

variable "alarm_cpu_utilization_maximum_percent" {
  description = "(optional) Alarm when node CPU utilization exceeds this percentage"
  default     = 80
  type        = number
}