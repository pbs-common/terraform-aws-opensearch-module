#!/usr/bin/env bash
# Lists TODO/FIXME markers left in the module so they don't get lost before a release.
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

grep -rn --include='*.tf' --include='*.md' -E 'TODO|FIXME' . || echo "No TODO/FIXME markers found."
