#!/usr/bin/env bash
# Formats every .tf file in the root module and its examples. Safe to run anytime; it never
# touches state or talks to AWS.
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

terraform fmt -recursive .
