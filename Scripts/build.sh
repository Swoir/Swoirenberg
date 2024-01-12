#!/usr/bin/env sh

set -e

echo "Building Swoirenberg.xcframework for aarch64-apple-ios, aarch64-apple-darwin, and x86_64-apple-darwin"

IPHONEOS_DEPLOYMENT_TARGET=14.0 cargo build --manifest-path Rust/Cargo.toml --release --target aarch64-apple-ios
MACOSX_DEPLOYMENT_TARGET=10.15 cargo build --manifest-path Rust/Cargo.toml --release --target aarch64-apple-darwin
MACOSX_DEPLOYMENT_TARGET=10.15 cargo build --manifest-path Rust/Cargo.toml --release --target x86_64-apple-darwin
