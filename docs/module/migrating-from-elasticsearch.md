# Migrating from `aws_elasticsearch_domain`

Older PBS stacks provision OpenSearch through the legacy `aws_elasticsearch_domain` resource
(with `elasticsearch_version = "OpenSearch_X.Y"` -- the resource name is legacy, the engine
running underneath has been OpenSearch for a while). This module uses the current
`aws_opensearch_domain` resource instead. Terraform cannot rename a resource type in place, so
adopting this module for a domain created the old way needs a state move, not a plan-and-apply:

```sh
terraform state rm 'aws_elasticsearch_domain.this'
terraform import 'module.opensearch.aws_opensearch_domain.this' <domain-name>
```

(`terraform import` against a live account is a write to Terraform state, not to AWS -- but it
is still something to do deliberately, outside of CI, with the resulting plan reviewed for zero
changes before it's applied.)

Mapping of the old per-application variables to this module's inputs, based on the ECS-style
`elasticsearch_*` variables seen in older stacks:

| Old variable | This module |
|---|---|
| `elasticsearch_number_of_nodes` | `instance_count` |
| `elasticsearch_instance_type` | `instance_type` |
| `elasticsearch_ebs_vol_size` | `volume_size` |
| `elasticsearch_dedicated_master_enabled` | `dedicated_master_enabled` |
| `elasticsearch_dedicated_master_type` | `dedicated_master_type` |
| `elasticsearch_dedicated_master_count` | `dedicated_master_count` |
| `elasticsearch_high_master_jvm_pressure` | `alarm_jvm_memory_pressure_maximum_percent` (with `create_cloudwatch_alarms = true`) |
| `elasticsearch_high_node_jvm_pressure` | `alarm_jvm_memory_pressure_maximum_percent` (with `create_cloudwatch_alarms = true`) |
| hand-rolled `aws_security_group` + two `ingress` blocks | `ingress_rules` (see [access-control.md](./access-control.md)) |
| hand-rolled `aws_elasticsearch_domain_policy` | `access_policies` |
| hand-rolled `aws_cloudwatch_log_group` + `aws_cloudwatch_log_resource_policy` for `INDEX_SLOW_LOGS` | `log_publishing_options` (see [logging.md](./logging.md)) |

The legacy `snapshot_options { automated_snapshot_start_hour = ... }` block only matters for
Elasticsearch domains from before Amazon took over automated snapshots (version < 5.3); it's
exposed here as `automated_snapshot_start_hour` for parity but is a no-op on modern OpenSearch
domains and can usually be left null.
