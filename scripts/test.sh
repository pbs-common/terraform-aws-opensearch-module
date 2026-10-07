#!/usr/bin/env bash
# Runs the Terratest suite under tests/. These tests create and destroy real AWS resources;
# export AWS credentials with permission to manage OpenSearch domains before running this.
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir/tests"

go test -timeout 60m -v ./...
