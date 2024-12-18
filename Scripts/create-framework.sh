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

    # Create an Info.plist for each framework
    # This is required by XCode starting version 15.3
    for fw in "$@"; do
        {
        echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        echo "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"
        echo "<plist version=\"1.0\">"
        echo "<dict>"
        echo "    <key>CFBundlePackageType</key>"
        echo "    <string>FMWK</string>"
        echo "    <key>CFBundleIdentifier</key>"
        echo "    <string>com.swoirenberg.$FWNAME</string>"
        echo "    <key>CFBundleExecutable</key>"
        echo "    <string>$FWNAME</string>"
        echo "    <key>CFBundleShortVersionString</key>"
        echo "    <string>1.0.0-beta.0</string>"
        echo "    <key>CFBundleVersion</key>"
        echo "    <string>1</string>"
        if [ "$fw" = "aarch64-apple-ios" ]; then
            echo "    <key>MinimumOSVersion</key>"
            echo "    <string>15.0</string>"
        fi
        if [ "$fw" = "macos-arm64" ]; then
            echo "    <key>MinimumOSVersion</key>"
            echo "    <string>10.15</string>"
        fi
        echo "</dict>"
        echo "</plist>"
        } > ".artifacts/Frameworks/$fw/$FWNAME.framework/Info.plist"
    done

    rm -rf "Frameworks/$XCFWNAME.xcframework"
    xcrun xcodebuild -create-xcframework \
        "${fw_paths[@]}" \
        -output "Frameworks/$XCFWNAME.xcframework"

    # Set the SIGNING_IDENTITY environment variable to enable signing of the framework
    # It's the name of the certificate you want to use to sign the framework
    # e.g. "Apple Distribution: Company Name (ID)"
    if [ -n "$SIGNING_IDENTITY" ]; then
        codesign --timestamp -s "$SIGNING_IDENTITY" "Frameworks/$XCFWNAME.xcframework"
    fi
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
strip -x Rust/target/aarch64-apple-darwin/release/libswoirenberg.a Rust/target/aarch64-apple-ios/release/libswoirenberg.a

# Create universal arm64 module
mkdir -p Rust/target/macos-arm64/release
lipo -create -output Rust/target/macos-arm64/release/libswoirenberg.a \
    Rust/target/aarch64-apple-darwin/release/libswoirenberg.a

frameworks=("macos-arm64" "aarch64-apple-ios")
create_framework "${frameworks[@]}"

echo "Zipping framework"
pushd "Frameworks"
zip -X -9 -r "$XCFWNAME.xcframework.zip" "$XCFWNAME.xcframework" -i */SwoirenbergLib -i *.plist -i *.h -i *.modulemap
popd
echo "Created zipped framework at Frameworks/$XCFWNAME.xcframework.zip"
