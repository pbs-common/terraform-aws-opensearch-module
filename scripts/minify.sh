#!/usr/bin/env bash
# Prints the byte size of every tracked .tf file, largest first, as a quick sanity check that
# no example or generated file has ballooned unexpectedly.
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

git ls-files '*.tf' | xargs wc -c | sort -rn
