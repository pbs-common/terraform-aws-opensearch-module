#!/usr/bin/env bash
# Installs a pre-commit hook that runs validate.sh, format.sh, then document.sh, in that order.
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
hook_path="${root_dir}/.git/hooks/pre-commit"

cat > "$hook_path" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
root_dir="$(git rev-parse --show-toplevel)"
"$root_dir/scripts/validate.sh"
"$root_dir/scripts/format.sh"
"$root_dir/scripts/document.sh"
EOF

chmod +x "$hook_path"
echo "Installed pre-commit hook at ${hook_path}"
