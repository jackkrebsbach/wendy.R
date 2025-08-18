#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WENDY_DIR="$ROOT_DIR/src/core"
EXT_DIR="$WENDY_DIR/external"
PKG_DIR="$ROOT_DIR"
INST_INCLUDE_DIR="$PKG_DIR/inst/include"

echo "==> Clean build artifacts"
# Remove object files and shared libraries in the package root and src/core
find "$PKG_DIR" -name '*.o' -delete
find "$PKG_DIR" -name '*.so' -delete
find "$WENDY_DIR" -name '*.o' -delete
find "$WENDY_DIR" -name '*.so' -delete

# Remove previous build directories if present
rm -rf "$PKG_DIR"/build
rm -rf "$PKG_DIR"/.Rbuildignore
rm -rf "$PKG_DIR"/.Rhistory
rm -rf "$PKG_DIR"/.RData
rm -rf "$PKG_DIR"/.Rproj.user

# Remove any previous installed/locked package in R's site-library
if [ -d "/opt/homebrew/lib/R/4.5/site-library/00LOCK-wendy" ]; then
  echo "==> Removing previous 00LOCK-wendy"
  rm -rf "/opt/homebrew/lib/R/4.5/site-library/00LOCK-wendy"
fi

if [ -d "/opt/homebrew/lib/R/4.5/site-library/wendy" ]; then
  echo "==> Removing previous wendy install"
  rm -rf "/opt/homebrew/lib/R/4.5/site-library/wendy"
fi

echo "==> Rcpp attributes + build tarball"
cd "$PKG_DIR"
Rscript -e "Rcpp::compileAttributes('.')"

echo "==> Rcpp attributes + install"
R CMD INSTALL . --clean