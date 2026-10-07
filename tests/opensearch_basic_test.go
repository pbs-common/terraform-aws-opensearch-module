package test

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestOpensearchBasic applies examples/basic (a public domain, no VPC) and asserts the domain
// comes up with the endpoint outputs this module promises.
func TestOpensearchBasic(t *testing.T) {
	t.Parallel()

	opts := opensearchExampleOptions(t, "basic", nil)

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	endpoint := terraform.Output(t, opts, "endpoint")
	assert.NotEmpty(t, endpoint)
	assert.False(t, strings.Contains(endpoint, "vpc-"), "basic example should not be a VPC endpoint")

	domainID := terraform.Output(t, opts, "domain_id")
	assert.NotEmpty(t, domainID)
}
