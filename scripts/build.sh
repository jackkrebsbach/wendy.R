#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WENDY_DIR="$ROOT_DIR/wendy"
EXT_DIR="$ROOT_DIR/external"
BUILD_DIR="$WENDY_DIR/build"
PKG_DIR="$ROOT_DIR/pkg"
INST_INCLUDE_DIR="$PKG_DIR/inst/include"

echo "==> Build libwendy.a"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

JOBS="$({ getconf _NPROCESSORS_ONLN 2>/dev/null || true; } || { nproc 2>/dev/null || true; } || echo 4)"

cmake -S "$WENDY_DIR" -B "$BUILD_DIR" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="$BUILD_DIR" \
  -DCMAKE_LIBRARY_OUTPUT_DIRECTORY="$BUILD_DIR" \
  -DEigen3_DIR=/opt/homebrew/share/eigen3/cmake \
  -DCeres_DIR=/opt/homebrew/Cellar/ceres-solver/2.2.0_1.reinstall/lib/cmake/Ceres

cmake --build "$BUILD_DIR" --target wendy -j"$JOBS"

echo "==> Stage static lib into pkg/src"
mkdir -p "$PKG_DIR/src"
cp -f "$BUILD_DIR/libwendy.a" "$PKG_DIR/src/libwendy.a"

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
R CMD build .

echo "Done. lib: $BUILD_DIR/libwendy.a | headers: $INST_INCLUDE_DIR"
