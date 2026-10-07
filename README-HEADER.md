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
