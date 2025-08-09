#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WENDY_DIR="$ROOT_DIR/src/core"
EXT_DIR="$ROOT_DIR/external"
PKG_DIR="$ROOT_DIR"
INST_INCLUDE_DIR="$PKG_DIR/inst/include"

echo "==> Vendor headers into pkg/inst/include"
rm -rf "$INST_INCLUDE_DIR"
mkdir -p "$INST_INCLUDE_DIR"

# Copy wendy/include contents
rsync -a --delete "$WENDY_DIR/include/" "$INST_INCLUDE_DIR/"

# Copy each top-level folder from external/*/include into inst/include/<top>/
# so nothing clobbers anything else, and --delete only prunes per-subdir.
shopt -s nullglob
for dep in "$EXT_DIR"/*; do
  [[ -d "$dep/include" ]] || continue
  for top in "$dep/include"/*; do
    base="$(basename "$top")"
    rsync -a --delete "$top/" "$INST_INCLUDE_DIR/$base/"
  done
done
shopt -u nullglob

echo "==> Rcpp attributes + build tarball"
cd "$PKG_DIR"
Rscript -e "Rcpp::compileAttributes('.')"

echo "==> Rcpp attributes + install"
cd "$PKG_DIR"
Rscript -e "Rcpp::compileAttributes('.')"

R CMD INSTALL .

