#!/usr/bin/env sh

set -e

echo "Building Swoirenberg.xcframework for aarch64-apple-ios and aarch64-apple-darwin"

IPHONEOS_DEPLOYMENT_TARGET=15.0 cargo build --manifest-path Rust/Cargo.toml --release --target aarch64-apple-ios -vvvv
MACOSX_DEPLOYMENT_TARGET=13.0 cargo build --manifest-path Rust/Cargo.toml --release --target aarch64-apple-darwin -vvvv
#MACOSX_DEPLOYMENT_TARGET=10.15 cargo build --manifest-path Rust/Cargo.toml --release --target x86_64-apple-darwin -vvvv
