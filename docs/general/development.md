# Development

Requires `terraform` >= 1.13, `tflint`, and `terraform-docs`. `tests/` additionally needs `go` >= 1.22.

```sh
scripts/setup-hooks.sh   # one-time: installs the pre-commit hook
scripts/validate.sh      # terraform init -backend=false && terraform validate, for the module and every example
scripts/format.sh        # terraform fmt -recursive
scripts/lint.sh          # tflint, for the module and every example
scripts/document.sh      # regenerates README.md from README-HEADER.md -- never hand-edit README.md
```

Run them in that order; the pre-commit hook runs `validate.sh`, `format.sh` and `document.sh` automatically.

Edit `README-HEADER.md`, not `README.md`, for anything in the Installation/Usage sections.
