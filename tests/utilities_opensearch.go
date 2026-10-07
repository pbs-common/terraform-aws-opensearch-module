package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// opensearchExampleOptions builds the terraform.Options for an examples/<variant> directory,
// so each test only has to supply the variant name and any var overrides.
func opensearchExampleOptions(t *testing.T, variant string, vars map[string]interface{}) *terraform.Options {
	t.Helper()

	return terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/" + variant,
		Vars:         vars,
		NoColor:      true,
	})
}
