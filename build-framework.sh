#!/usr/bin/env sh

IPHONEOS_DEPLOYMENT_TARGET=14.0 cargo build --manifest-path Rust/Cargo.toml --release --target aarch64-apple-ios && \
MACOSX_DEPLOYMENT_TARGET=10.15 cargo build --manifest-path Rust/Cargo.toml --release --target aarch64-apple-darwin && \
MACOSX_DEPLOYMENT_TARGET=10.15 cargo build --manifest-path Rust/Cargo.toml --release --target x86_64-apple-darwin && \
rustc Rust/post-build.rs -L Rust/target/release/deps/ -o Rust/.artifacts/post-build && (cd Rust && .artifacts/post-build; cd ..)
