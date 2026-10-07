# Module Documentation

- [Choosing an access control model](./access-control.md)
- [Log publishing](./logging.md)
- [Migrating from `aws_elasticsearch_domain`](./migrating-from-elasticsearch.md)

See `examples/` for complete, runnable configurations of each pattern:

| Example | Pattern |
|---|---|
| `examples/basic` | Minimal public domain, required parameters only |
| `examples/vpc-private` | VPC domain reached only from an application security group, open resource policy |
| `examples/public-managed-logs` | Public domain, IAM request signing, logs to a pre-existing log group |
| `examples/full-featured` | Dedicated masters, UltraWarm + cold storage, fine-grained access control, custom endpoint, every log type, alarms |
