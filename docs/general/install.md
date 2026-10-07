# Installation

## Using the Repo Source

```hcl
module "opensearch" {
  source = "github.com/pbs/terraform-aws-opensearch-module?ref=x.y.z"
  # ...
}
```

Pin `ref` to a tagged release (see the repo's tags). Never reference a branch.

## As a Git Subtree

```sh
git subtree add --prefix=modules/opensearch git@github.com:pbs/terraform-aws-opensearch-module.git x.y.z --squash
```

Then source it locally:

```hcl
module "opensearch" {
  source = "./modules/opensearch"
  # ...
}
```

Pulling in a new version is a `git subtree pull` against the same ref.
