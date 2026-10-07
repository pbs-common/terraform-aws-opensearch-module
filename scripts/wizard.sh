#!/usr/bin/env bash
# Interactively prints a minimal module call, prompting only for the handful of inputs most
# callers need to change (tagging parameters plus networking). Pipe the output into a new .tf
# file and adjust from there -- this does not write any files itself.
set -euo pipefail

read -rp "product: " product
read -rp "owner: " owner
read -rp "environment [sharedtools/dev/staging/qa/prod]: " environment
read -rp "organization: " organization
read -rp "repo (git URL): " repo
read -rp "Place the domain in a VPC? [y/N]: " use_vpc

cat <<EOF

module "opensearch" {
  source = "github.com/pbs/terraform-aws-opensearch-module?ref=x.y.z"

  # Tagging Parameters
  organization = "${organization}"
  environment  = "${environment}"
  product      = "${product}"
  owner        = "${owner}"
  repo         = "${repo}"
EOF

if [[ "${use_vpc,,}" == "y" ]]; then
  cat <<'EOF'

  # Optional Parameters
  vpc_id     = "vpc-xxxxxxxxxxxxxxxxx"
  subnet_ids = ["subnet-xxxxxxxxxxxxxxxxx"]
EOF
fi

echo "}"
