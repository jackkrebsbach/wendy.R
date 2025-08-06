#!/usr/bin/env bash

set -e  # Exit on error

PKGNAME=wendy

echo "==> Generating Rcpp attributes..."
Rscript -e "Rcpp::compileAttributes('.')"

echo "==> Building package..."
R CMD build .

TARBALL=$(ls -t ${PKGNAME}_*.tar.gz | head -n 1)

echo "==> Installing package..."
R CMD INSTALL "$TARBALL"

echo "==> Cleaning up build tarball..."
rm -f "$TARBALL"

echo "==> Done."
