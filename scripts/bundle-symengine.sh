#!/usr/bin/env bash
set -e

SYMENGINE_REPO="symengine/symengine"
SYMENGINE_COMMIT="v0.14.0"

WORKDIR=$(mktemp -d)
TARBALL="src/symengine.tar.gz"

# Download and extract
curl -L "https://github.com/$SYMENGINE_REPO/archive/$SYMENGINE_COMMIT.tar.gz" | \
    tar -xz -C "$WORKDIR"

# The extracted directory will be $WORKDIR/symengine-<version>
EXTRACTED="$WORKDIR/symengine-${SYMENGINE_COMMIT#v}"

# Remove unnecessary files
rm -rf "$EXTRACTED/tests" \
       "$EXTRACTED/benchmarks" \
       "$EXTRACTED/docs" \
       "$EXTRACTED/binder" \
       "$EXTRACTED/bin"

# Create the tarball in src/
mkdir -p src
tar -czf "$TARBALL" -C "$WORKDIR" "$(basename "$EXTRACTED")"

# Clean up
rm -rf "$WORKDIR"

echo "✅ Bundled SymEngine as $TARBALL"
