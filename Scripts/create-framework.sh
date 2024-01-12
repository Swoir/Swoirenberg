#!/usr/bin/env sh

set -e

XCFWNAME="Swoirenberg"
FWNAME="SwoirenbergLib"

function create_framework() {
    for fw in "$@"; do
        copy_framework_files "${fw}"
    done

    local fw_paths=()
    for fw in "$@"; do
        fw_paths+=("-framework" ".artifacts/Frameworks/${fw}/$FWNAME.framework")
    done
    rm -rf "Frameworks/$XCFWNAME.xcframework"
    xcrun xcodebuild -create-xcframework \
        "${fw_paths[@]}" \
        -output "Frameworks/$XCFWNAME.xcframework"
}

function copy_framework_files() {
    rm -rf ".artifacts/Frameworks/$1"

    local FRAMEWORK_PATH=".artifacts/Frameworks/$1/SwoirenbergLib.framework"
    mkdir -p "$FRAMEWORK_PATH/Headers"
    cp .artifacts/swift-bridge/SwiftBridge/SwiftBridge.h .artifacts/swift-bridge/SwiftBridgeCore.h $FRAMEWORK_PATH/Headers
    {
    echo "#include <SwoirenbergLib/SwiftBridgeCore.h>"
    echo "#include <SwoirenbergLib/SwiftBridge.h>"
    } > $FRAMEWORK_PATH/Headers/SwoirenbergLib.h

    mkdir -p $FRAMEWORK_PATH/Modules
    {
    echo "framework module SwoirenbergLib {"
    echo "\tumbrella header \"SwoirenbergLib.h\""
    echo "\texport *"
    echo "\tmodule * { export * }"
    echo "}"
    } > $FRAMEWORK_PATH/Modules/module.modulemap

    cp Rust/target/$1/release/libswoirenberg.a $FRAMEWORK_PATH/SwoirenbergLib
}

# Strip debug symbols to reduce module size
strip -x Rust/target/x86_64-apple-darwin/release/libswoirenberg.a Rust/target/aarch64-apple-darwin/release/libswoirenberg.a Rust/target/aarch64-apple-ios/release/libswoirenberg.a

# Create universal arm64_x86_64 module
mkdir -p Rust/target/macos-arm64_x86_64/release
lipo -create -output Rust/target/macos-arm64_x86_64/release/libswoirenberg.a \
    Rust/target/aarch64-apple-darwin/release/libswoirenberg.a \
    Rust/target/x86_64-apple-darwin/release/libswoirenberg.a

frameworks=("macos-arm64_x86_64" "aarch64-apple-ios")
create_framework "${frameworks[@]}"

echo "Zipping framework"
pushd "Frameworks"
zip -X -9 -r "$XCFWNAME.xcframework.zip" "$XCFWNAME.xcframework" -i */SwoirenbergLib -i *.plist -i *.h -i *.modulemap
popd
echo "Created zipped framework at Frameworks/$XCFWNAME.xcframework.zip"
