# Tests

`tests/` holds Terratest Go tests, one example per test file, that `terraform init && apply`
one of the `examples/*` directories against real AWS resources and then `destroy` it.

```sh
scripts/test.sh
```

This creates and destroys real OpenSearch domains, so it needs AWS credentials with permission
to manage them (not the read-only credentials used for investigation work) and takes a while --
OpenSearch domain creation alone typically takes 15-20 minutes.

Add a new test by adding an `examples/<variant>` directory and a matching
`tests/opensearch_<variant>_test.go` that calls `opensearchExampleOptions(t, "<variant>", vars)`
from `tests/utilities_opensearch.go`.
