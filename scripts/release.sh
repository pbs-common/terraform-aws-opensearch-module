#!/usr/bin/env bash
# Tags and publishes a new release. Bump is "major", "minor" or "patch" (default: patch) --
# see README.md's contribution notes for when each applies. Requires a clean tree and the gh CLI.
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"

bump="${1:-patch}"
case "$bump" in
  major|minor|patch) ;;
  *) echo "usage: $0 [major|minor|patch]" >&2; exit 1 ;;
esac

if [[ -n "$(git status --porcelain)" ]]; then
  echo "working tree is not clean; commit or stash before releasing" >&2
  exit 1
fi

latest_tag="$(git tag --list 'v[0-9]*.[0-9]*.[0-9]*' --sort=-v:refname | head -n1)"
latest_tag="${latest_tag:-v0.0.0}"
IFS='.' read -r major minor patch <<< "${latest_tag#v}"

case "$bump" in
  major) major=$((major + 1)); minor=0; patch=0 ;;
  minor) minor=$((minor + 1)); patch=0 ;;
  patch) patch=$((patch + 1)) ;;
esac

new_version="${major}.${minor}.${patch}"
new_tag="v${new_version}"

sed -i.bak -E "s/ref=x\.y\.z/ref=${new_version}/g; s/\`x\.y\.z\`/\`${new_version}\`/g" README.md README-HEADER.md
rm -f README.md.bak README-HEADER.md.bak

git add README.md README-HEADER.md
git commit -m "Release ${new_tag}"
git tag -a "$new_tag" -m "${new_tag}"
git push origin HEAD "$new_tag"

if command -v gh >/dev/null; then
  gh release create "$new_tag" --generate-notes
else
  echo "gh CLI not found; tag ${new_tag} pushed but no GitHub release was created" >&2
fi
