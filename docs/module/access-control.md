# Choosing an access control model

The domain supports three ways to restrict access, and this module lets you combine them; pick
based on where traffic to the domain originates.

## VPC + security group (`subnet_ids` set)

Set `subnet_ids` (and `vpc_id`, unless `create_security_group = false`). The domain gets a
private IP in your VPC and this module creates a security group for it, opened to whatever
`ingress_rules` you give it (typically the security group of the application that talks to the
domain).

Because network access is already restricted by the security group, `access_policies` is
commonly left wide open (`Principal: "*"`) -- the security group is doing the real access
control, not the policy. This is the pattern used by ECS-based applications that reach
OpenSearch only from inside the VPC.

## Public domain, IAM request signing (`subnet_ids` left empty, `access_policies` left null)

Leave `subnet_ids` empty and don't set `access_policies`. The domain gets a public endpoint, and
because no resource policy is attached, AWS evaluates each request purely against the calling
principal's own IAM identity policy (the same model S3 uses when a bucket has no bucket policy).
Callers must sign requests with SigV4 using a role/user whose IAM policy allows
`es:ESHttp*` on the domain's ARN -- there is no anonymous or policy-based access.

This is the simpler option when every caller already has an IAM role and you don't want to
manage a VPC attachment, security groups, or a resource policy.

## Public domain, resource policy (`subnet_ids` left empty, `access_policies` set)

Leave `subnet_ids` empty and pass `access_policies` as JSON, e.g. restricted to specific IAM
principal ARNs or source IP ranges. Use this when you need a public endpoint but can't put every
caller behind IAM-signed requests (for example, allow-listing a fixed set of office/VPN CIDRs).

## Fine-grained access control

Set `advanced_security_options_enabled = true` for per-user/role permissions inside OpenSearch
itself (index-level and field-level security), on top of whichever network/IAM model above you
picked. It requires `encrypt_at_rest_enabled`, `node_to_node_encryption_enabled` and
`enforce_https` to all be true (the module's defaults). Choose `internal_user_database_enabled`
for a master username/password managed by OpenSearch, or supply `master_user_arn` instead to use
an IAM principal as the master user.
