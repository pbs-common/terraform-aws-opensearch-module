# Log publishing

`log_publishing_options` takes a map keyed by OpenSearch log type
(`INDEX_SLOW_LOGS`, `SEARCH_SLOW_LOGS`, `ES_APPLICATION_LOGS`, `AUDIT_LOGS`). Omit a key to leave
that log type off; an empty object (`{}`) turns a log type on with this module managing its log
group:

```hcl
log_publishing_options = {
  INDEX_SLOW_LOGS = {}
  ES_APPLICATION_LOGS = {
    retention_in_days = 90
  }
}
```

For each entry where `cloudwatch_log_group_arn` is left null (the default) and `create_log_group`
is left `true` (also the default), this module creates the `aws_cloudwatch_log_group` and a single
`aws_cloudwatch_log_resource_policy` granting `es.amazonaws.com` permission to write to it --
OpenSearch domains cannot publish logs to a group that doesn't grant them that permission, and
AWS does not create it automatically.

If the log group already exists (and already carries that resource policy) -- for example when
it's created by a different stack, or when you're migrating a domain created outside this module
-- point `cloudwatch_log_group_arn` at it directly instead:

```hcl
log_publishing_options = {
  ES_APPLICATION_LOGS = {
    cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/OpenSearchService/domains/my-domain/application-logs"
  }
}
```

`AUDIT_LOGS` additionally requires `advanced_security_options_enabled = true`.
