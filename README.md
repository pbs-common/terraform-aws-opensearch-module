# PBS TF OpenSearch Module

## Installation

### Using the Repo Source

```hcl
github.com/pbs/terraform-aws-opensearch-module?ref=x.y.z
```

### Alternative Installation Methods

More information can be found on these install methods and more in [the documentation here](./docs/general/install).

## Usage

This module provisions an `aws_opensearch_domain` and the handful of resources it typically
needs alongside it: a security group (when placed in a VPC), a domain access policy (when one is
given), CloudWatch log groups plus the resource policy that lets OpenSearch write to them, and a
common set of CloudWatch alarms.

By default it creates a small, public, encrypted-at-rest single-node domain with no VPC
attachment, no access policy (access is controlled by the calling principal's own IAM policy),
and no logging or alarms -- every other feature is opt-in. See
[docs/module](./docs/module) for how to choose an access control model, configure log
publishing, and migrate a domain off the legacy `aws_elasticsearch_domain` resource, and
`examples/` for complete configurations ranging from minimal to a dedicated-master,
UltraWarm/cold-storage, fine-grained-access-control domain.

Integrate this module like so:

```hcl
module "opensearch" {
  source = "github.com/pbs/terraform-aws-opensearch-module?ref=x.y.z"

  # Tagging Parameters
  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo

  # Optional Parameters
  subnet_ids = var.subnet_ids
  vpc_id     = var.vpc_id

  instance_type  = "r6g.large.search"
  instance_count = 2

  log_publishing_options = {
    INDEX_SLOW_LOGS = {}
  }

  create_cloudwatch_alarms = true
  alarm_actions            = [var.sns_topic_arn]
}
```

## Adding This Version of the Module

If this repo is added as a subtree, then the version of the module should be close to the version shown here:

`x.y.z`

Note, however that subtrees can be altered as desired within repositories.

Further documentation on usage can be found [here](./docs).

Below is automatically generated documentation on this Terraform module using [terraform-docs][terraform-docs]

---

[terraform-docs]: https://github.com/terraform-docs/terraform-docs

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_cloudwatch_metric_alarm.cluster_index_writes_blocked](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cluster_status_red](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cluster_status_yellow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.free_storage_space](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.master_jvm_memory_pressure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.node_jvm_memory_pressure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_opensearch_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain) | resource |
| [aws_opensearch_domain_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain_policy) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_default_tags.common_tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (sharedtools, dev, staging, qa, prod) | `string` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | Organization using this module. Used to prefix tags so that they are easily identified as being from your organization | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Tag used to group resources according to product | `string` | n/a | yes |
| <a name="input_product"></a> [product](#input\_product) | Tag used to group resources according to product | `string` | n/a | yes |
| <a name="input_repo"></a> [repo](#input\_repo) | Tag used to point to the repo using this module | `string` | n/a | yes |
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | (optional) Raw JSON access policy document for the domain. Leave null to manage access purely through the security group (VPC domains) or through IAM request signing (public domains). | `string` | `null` | no |
| <a name="input_advanced_security_options_enabled"></a> [advanced\_security\_options\_enabled](#input\_advanced\_security\_options\_enabled) | (optional) Whether to enable fine-grained access control. Requires encrypt\_at\_rest\_enabled, node\_to\_node\_encryption\_enabled and enforce\_https to all be true. | `bool` | `false` | no |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (optional) ARNs (e.g. SNS topics) notified when an alarm created by create\_cloudwatch\_alarms transitions into ALARM | `list(string)` | `[]` | no |
| <a name="input_alarm_cpu_utilization_maximum_percent"></a> [alarm\_cpu\_utilization\_maximum\_percent](#input\_alarm\_cpu\_utilization\_maximum\_percent) | (optional) Alarm when node CPU utilization exceeds this percentage | `number` | `80` | no |
| <a name="input_alarm_free_storage_space_minimum_mb"></a> [alarm\_free\_storage\_space\_minimum\_mb](#input\_alarm\_free\_storage\_space\_minimum\_mb) | (optional) Alarm when the least-free data node has fewer than this many megabytes of free storage left | `number` | `10240` | no |
| <a name="input_alarm_jvm_memory_pressure_maximum_percent"></a> [alarm\_jvm\_memory\_pressure\_maximum\_percent](#input\_alarm\_jvm\_memory\_pressure\_maximum\_percent) | (optional) Alarm when node (and, with dedicated\_master\_enabled, master) JVM memory pressure exceeds this percentage | `number` | `80` | no |
| <a name="input_auto_tune_enabled"></a> [auto\_tune\_enabled](#input\_auto\_tune\_enabled) | (optional) Whether to enable Auto-Tune performance recommendations | `bool` | `false` | no |
| <a name="input_auto_tune_rollback_on_disable"></a> [auto\_tune\_rollback\_on\_disable](#input\_auto\_tune\_rollback\_on\_disable) | (optional) Whether to roll back Auto-Tune changes when Auto-Tune is disabled | `string` | `"NO_ROLLBACK"` | no |
| <a name="input_automated_snapshot_start_hour"></a> [automated\_snapshot\_start\_hour](#input\_automated\_snapshot\_start\_hour) | (optional) UTC hour at which automated daily snapshots are taken. Only meaningful for legacy Elasticsearch domains without encrypt\_at\_rest\_enabled; modern OpenSearch domains manage snapshots automatically. Leave null to omit the block. | `number` | `null` | no |
| <a name="input_availability_zone_count"></a> [availability\_zone\_count](#input\_availability\_zone\_count) | (optional) Number of availability zones used when zone\_awareness\_enabled is true | `number` | `2` | no |
| <a name="input_cold_storage_enabled"></a> [cold\_storage\_enabled](#input\_cold\_storage\_enabled) | (optional) Whether to enable cold storage (requires warm\_enabled) | `bool` | `false` | no |
| <a name="input_create_cloudwatch_alarms"></a> [create\_cloudwatch\_alarms](#input\_create\_cloudwatch\_alarms) | (optional) Whether to create the common set of CloudWatch alarms for this domain (cluster status, free storage, JVM memory pressure, CPU utilization) | `bool` | `false` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | (optional) Whether to create a security group for the domain when subnet\_ids is set | `bool` | `true` | no |
| <a name="input_custom_endpoint"></a> [custom\_endpoint](#input\_custom\_endpoint) | (optional) Custom hostname for the domain endpoint (required when custom\_endpoint\_enabled is true) | `string` | `null` | no |
| <a name="input_custom_endpoint_certificate_arn"></a> [custom\_endpoint\_certificate\_arn](#input\_custom\_endpoint\_certificate\_arn) | (optional) ACM certificate ARN for the custom endpoint (required when custom\_endpoint\_enabled is true) | `string` | `null` | no |
| <a name="input_custom_endpoint_enabled"></a> [custom\_endpoint\_enabled](#input\_custom\_endpoint\_enabled) | (optional) Whether to serve the domain on a custom hostname | `bool` | `false` | no |
| <a name="input_dedicated_master_count"></a> [dedicated\_master\_count](#input\_dedicated\_master\_count) | (optional) Number of dedicated master nodes (only used when dedicated\_master\_enabled is true); AWS requires 3 or 5 | `number` | `3` | no |
| <a name="input_dedicated_master_enabled"></a> [dedicated\_master\_enabled](#input\_dedicated\_master\_enabled) | (optional) Whether to use dedicated master nodes | `bool` | `false` | no |
| <a name="input_dedicated_master_type"></a> [dedicated\_master\_type](#input\_dedicated\_master\_type) | (optional) Instance type for dedicated master nodes (only used when dedicated\_master\_enabled is true) | `string` | `"t3.small.search"` | no |
| <a name="input_ebs_enabled"></a> [ebs\_enabled](#input\_ebs\_enabled) | (optional) Whether data nodes use EBS storage instead of instance store | `bool` | `true` | no |
| <a name="input_egress_cidr_blocks"></a> [egress\_cidr\_blocks](#input\_egress\_cidr\_blocks) | (optional) CIDR blocks allowed on all outbound traffic from the security group this module creates | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_encrypt_at_rest_enabled"></a> [encrypt\_at\_rest\_enabled](#input\_encrypt\_at\_rest\_enabled) | (optional) Whether to encrypt data at rest | `bool` | `true` | no |
| <a name="input_enforce_https"></a> [enforce\_https](#input\_enforce\_https) | (optional) Whether to require HTTPS for all traffic to the domain endpoint | `bool` | `true` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | (optional) Engine version, e.g. OpenSearch\_2.19 or Elasticsearch\_7.10 | `string` | `"OpenSearch_2.19"` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | (optional) Ingress rules added to the security group this module creates. Each rule allows either cidr\_blocks or security\_group\_ids (or both). | <pre>list(object({<br/>    description        = optional(string)<br/>    from_port          = optional(number, 443)<br/>    to_port            = optional(number, 443)<br/>    protocol           = optional(string, "tcp")<br/>    cidr_blocks        = optional(list(string), [])<br/>    security_group_ids = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | (optional) Number of data nodes | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | (optional) Instance type for data nodes | `string` | `"t3.small.search"` | no |
| <a name="input_internal_user_database_enabled"></a> [internal\_user\_database\_enabled](#input\_internal\_user\_database\_enabled) | (optional) Whether to use the built-in user database for fine-grained access control instead of an IAM master user | `bool` | `true` | no |
| <a name="input_iops"></a> [iops](#input\_iops) | (optional) Baseline IOPS for gp3/io1/io2 volumes (defaults to the EBS volume type's own default when null) | `number` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | (optional) KMS key id/ARN used for encryption at rest (defaults to the AWS-owned key when null) | `string` | `null` | no |
| <a name="input_log_publishing_options"></a> [log\_publishing\_options](#input\_log\_publishing\_options) | (optional) Map of OpenSearch log types to publish to CloudWatch Logs. Keys must be one of INDEX\_SLOW\_LOGS, SEARCH\_SLOW\_LOGS, ES\_APPLICATION\_LOGS or AUDIT\_LOGS. When cloudwatch\_log\_group\_arn is left null and create\_log\_group is left true (the defaults), the module creates and manages that log group, plus the CloudWatch resource policy letting the OpenSearch service write to it. Set cloudwatch\_log\_group\_arn to point at a log group managed elsewhere instead. | <pre>map(object({<br/>    cloudwatch_log_group_arn = optional(string)<br/>    create_log_group         = optional(bool, true)<br/>    retention_in_days        = optional(number, 30)<br/>  }))</pre> | `{}` | no |
| <a name="input_master_user_arn"></a> [master\_user\_arn](#input\_master\_user\_arn) | (optional) IAM ARN of the master user for fine-grained access control (used instead of master\_user\_name/master\_user\_password when internal\_user\_database\_enabled is false) | `string` | `null` | no |
| <a name="input_master_user_name"></a> [master\_user\_name](#input\_master\_user\_name) | (optional) Master username for the internal user database (used when internal\_user\_database\_enabled is true) | `string` | `null` | no |
| <a name="input_master_user_password"></a> [master\_user\_password](#input\_master\_user\_password) | (optional) Master password for the internal user database (used when internal\_user\_database\_enabled is true) | `string` | `null` | no |
| <a name="input_multi_az_with_standby_enabled"></a> [multi\_az\_with\_standby\_enabled](#input\_multi\_az\_with\_standby\_enabled) | (optional) Whether to deploy a standby availability zone for faster failover (requires zone\_awareness\_enabled) | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | (optional) Name of the OpenSearch domain (defaults to product if null) | `string` | `null` | no |
| <a name="input_node_to_node_encryption_enabled"></a> [node\_to\_node\_encryption\_enabled](#input\_node\_to\_node\_encryption\_enabled) | (optional) Whether to encrypt traffic between nodes | `bool` | `true` | no |
| <a name="input_off_peak_window_enabled"></a> [off\_peak\_window\_enabled](#input\_off\_peak\_window\_enabled) | (optional) Whether to restrict Auto-Tune and other maintenance actions to an off-peak window | `bool` | `true` | no |
| <a name="input_off_peak_window_start_hour"></a> [off\_peak\_window\_start\_hour](#input\_off\_peak\_window\_start\_hour) | (optional) UTC hour the off-peak maintenance window starts | `number` | `2` | no |
| <a name="input_off_peak_window_start_minute"></a> [off\_peak\_window\_start\_minute](#input\_off\_peak\_window\_start\_minute) | (optional) Minute of the hour the off-peak maintenance window starts | `number` | `0` | no |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (optional) ARNs (e.g. SNS topics) notified when an alarm created by create\_cloudwatch\_alarms transitions back to OK | `list(string)` | `[]` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | (optional) Extra security group ids to attach to the domain, in addition to the one this module creates. Required if create\_security\_group is false and subnet\_ids is set. | `list(string)` | `[]` | no |
| <a name="input_software_update_auto_update_enabled"></a> [software\_update\_auto\_update\_enabled](#input\_software\_update\_auto\_update\_enabled) | (optional) Whether to automatically apply service software updates during the off-peak window | `bool` | `true` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | (optional) Subnet ids to place the domain in. One subnet per availability zone used; leave empty to create a public (non-VPC) domain | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Extra tags | `map(string)` | `{}` | no |
| <a name="input_throughput"></a> [throughput](#input\_throughput) | (optional) Throughput in MiB/s for gp3 volumes (defaults to the EBS volume type's own default when null) | `number` | `null` | no |
| <a name="input_tls_security_policy"></a> [tls\_security\_policy](#input\_tls\_security\_policy) | (optional) Minimum TLS version / cipher policy for the domain endpoint | `string` | `"Policy-Min-TLS-1-2-PFS-2023-10"` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | (optional) EBS volume size in GiB per data node | `number` | `20` | no |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | (optional) EBS volume type | `string` | `"gp3"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (optional) VPC id the security group this module creates is placed in. Required when subnet\_ids is set and create\_security\_group is true. | `string` | `null` | no |
| <a name="input_warm_count"></a> [warm\_count](#input\_warm\_count) | (optional) Number of UltraWarm nodes (only used when warm\_enabled is true) | `number` | `2` | no |
| <a name="input_warm_enabled"></a> [warm\_enabled](#input\_warm\_enabled) | (optional) Whether to enable UltraWarm nodes for infrequently-accessed data | `bool` | `false` | no |
| <a name="input_warm_type"></a> [warm\_type](#input\_warm\_type) | (optional) Instance type for UltraWarm nodes (only used when warm\_enabled is true) | `string` | `"ultrawarm1.medium.search"` | no |
| <a name="input_zone_awareness_enabled"></a> [zone\_awareness\_enabled](#input\_zone\_awareness\_enabled) | (optional) Whether to spread data nodes across multiple availability zones | `bool` | `false` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dashboard_endpoint"></a> [dashboard\_endpoint](#output\_dashboard\_endpoint) | Domain-specific endpoint for OpenSearch Dashboards |
| <a name="output_domain_arn"></a> [domain\_arn](#output\_domain\_arn) | ARN of the OpenSearch domain |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | Id of the OpenSearch domain |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | Name of the OpenSearch domain |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Domain-specific endpoint used to submit index, search, and data upload requests |
| <a name="output_kibana_endpoint"></a> [kibana\_endpoint](#output\_kibana\_endpoint) | Deprecated alias of dashboard\_endpoint, kept for callers migrating from aws\_elasticsearch\_domain |
| <a name="output_log_group_arns"></a> [log\_group\_arns](#output\_log\_group\_arns) | Map of log type to the ARN of the CloudWatch log group this module created for it |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Id of the security group this module created, or null when create\_security\_group is false or the domain is public |
