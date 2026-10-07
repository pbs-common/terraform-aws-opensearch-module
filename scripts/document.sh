#!/usr/bin/env bash
# Regenerates README.md from README-HEADER.md plus the module's own variables/outputs.
# README.md is generated; never hand-edit it, edit README-HEADER.md instead.
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

command -v terraform-docs >/dev/null || {
  echo "terraform-docs is required: https://terraform-docs.io/user-guide/installation/" >&2
  exit 1
}

terraform-docs markdown --header-from README-HEADER.md . > README.md
git add README.md 2>/dev/null || true
