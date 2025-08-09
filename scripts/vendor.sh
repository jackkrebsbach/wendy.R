#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
DEST="$ROOT/external"
GITMODULES="$ROOT/.gitmodules"

# List of deps: "name tag"
deps=(
  "xtl 0.8.0"
  "xtensor 0.27.0"
  "xtensor-blas 0.22.0"
)

mkdir -p "$DEST" 

# Ensure .gitmodules exists
[ -f "$GITMODULES" ] || { echo "# Created automatically" > "$GITMODULES"; git add "$GITMODULES"; }

remove_submodule() {
  local path="$1"
  if git config -f "$GITMODULES" --get-regexp "submodule.$path.path" >/dev/null 2>&1; then
    echo "Removing stale submodule: $path"
    git submodule deinit -f "$path" || true
    git rm -f "$path" || true
    rm -rf ".git/modules/$path"
  fi
  rm -rf "$path"
}

# Clean up old submodules
for dep in "${deps[@]}"; do
  set -- $dep
  name="$1"
  remove_submodule "external/$name"
done
rm -rf .git/modules/external || true

# Add + checkout exact versions
for dep in "${deps[@]}"; do
  set -- $dep
  name="$1"
  tag="$2"
  repo_url="https://github.com/xtensor-stack/$name.git"

  echo "Adding $name @ $tag"
  git submodule add "$repo_url" "external/$name"

  (
    cd "$DEST/$name"
    git fetch --tags --depth 1 origin tag "$tag"
    git checkout "tags/$tag" --detach

    # Verify
    actual_tag="$(git describe --tags --exact-match 2>/dev/null || true)"
    if [[ "$actual_tag" != "$tag" ]]; then
      echo "ERROR: $name checked out to '$actual_tag', expected '$tag'"
      exit 1
    fi

    # Sparse checkout
    git config core.sparseCheckout true
    mkdir -p "$(git rev-parse --git-dir)/info"
    echo "include/" > "$(git rev-parse --git-dir)/info/sparse-checkout"
    echo "LICENSE" >> "$(git rev-parse --git-dir)/info/sparse-checkout"
    git read-tree -mu HEAD
  )

done

echo "✅ Vendored xtensor stack at locked versions."
