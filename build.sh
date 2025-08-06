#!/usr/bin/env bash

set -e  # Exit on error

PKGNAME=wendy
CORE_DIR="src/core"
BUILD_DIR="${CORE_DIR}/build"

echo "==> Building core C++ library (libwendy.a) with CMake..."

if [ -d "$BUILD_DIR" ]; then
  rm -rf "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

cmake -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
      -DEigen3_DIR=/opt/homebrew/share/eigen3/cmake \
      -DCeres_DIR=/opt/homebrew/Cellar/ceres-solver/2.2.0_1.reinstall/lib/cmake/Ceres \
      ..

cmake --build . --target wendy

cd ../../..

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
