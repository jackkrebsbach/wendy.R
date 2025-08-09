#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WENDY_DIR="$ROOT_DIR/src/core"
EXT_DIR="$ROOT_DIR/external"
PKG_DIR="$ROOT_DIR"
INST_INCLUDE_DIR="$PKG_DIR/inst/include"

echo "==> Vendor headers into inst/include"
rm -rf "$INST_INCLUDE_DIR"
mkdir -p "$INST_INCLUDE_DIR"

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

# Vendor Eigen headers (special case: no include/ directory)
EIGEN_SRC="$EXT_DIR/eigen"
if [[ -d "$EIGEN_SRC/Eigen" ]]; then
  rsync -a --delete "$EIGEN_SRC/Eigen/" "$INST_INCLUDE_DIR/Eigen/"
fi
if [[ -d "$EIGEN_SRC/unsupported" ]]; then
  rsync -a --delete "$EIGEN_SRC/unsupported/" "$INST_INCLUDE_DIR/unsupported/"
fi


echo "==> Rcpp attributes + build tarball"
cd "$PKG_DIR"
Rscript -e "Rcpp::compileAttributes('.')"

echo "==> Rcpp attributes + install"
R CMD INSTALL .

