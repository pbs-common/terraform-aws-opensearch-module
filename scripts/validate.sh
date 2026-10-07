#!/usr/bin/env bash
# Runs `terraform init -backend=false && terraform validate` against the root module and every
# example, without touching any remote backend or real AWS account.
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

dirs=(".")
for example in examples/*/; do
  dirs+=("${example%/}")
done

status=0
for dir in "${dirs[@]}"; do
  echo "==> validating ${dir}"
  if ! (cd "$dir" && terraform init -backend=false -input=false -upgrade=false >/dev/null && terraform validate); then
    status=1
  fi
done

exit "$status"
