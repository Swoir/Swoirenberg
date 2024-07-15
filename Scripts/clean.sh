#!/usr/bin/env sh

set -e

echo "Clearing artifacts and build outputs..."

rm -rf .artifacts
rm -rf Frameworks
rm -rf .build
cd Rust && cargo clean
rm -rf Cargo.lock
cd ..