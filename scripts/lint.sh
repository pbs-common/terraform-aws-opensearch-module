#!/usr/bin/env bash
# Runs tflint against the root module and every example using this repo's .tflint.hcl.
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

command -v tflint >/dev/null || {
  echo "tflint is required: https://github.com/terraform-linters/tflint" >&2
  exit 1
}

tflint --init --config="${root_dir}/.tflint.hcl" >/dev/null

dirs=(".")
for example in examples/*/; do
  dirs+=("${example%/}")
done

status=0
for dir in "${dirs[@]}"; do
  echo "==> linting ${dir}"
  if ! tflint --chdir="$dir" --config="${root_dir}/.tflint.hcl"; then
    status=1
  fi
done

exit "$status"
