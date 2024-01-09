extern crate sha2;
extern crate regex;

use std::env;
use std::fs;
use std::process::Command;
use std::io::{Result};
use sha2::{Sha256, Digest};

fn main() -> Result<()> {
    // Strip debug symbols to reduce module size
    println!("post-build.rs: Stripping debug symbols");
    Command::new("strip")
        .arg("-x")
        .arg("target/x86_64-apple-darwin/release/libswoirenberg.a")
        .arg("target/aarch64-apple-darwin/release/libswoirenberg.a")
        .arg("target/aarch64-apple-ios/release/libswoirenberg.a")
        .status()
        .expect("Error running strip")
        .success()
        .then_some(())
        .expect("Failed to strip debug symbols");

    // Create universal-apple-darwin module
    println!("post-build.rs: Creating universal-apple-darwin module");
    fs::create_dir_all("target/universal-apple-darwin/release")?;
    Command::new("lipo")
        .arg("-create")
        .args(&["-output", "target/universal-apple-darwin/release/libswoirenberg.a"])
        .arg("target/aarch64-apple-darwin/release/libswoirenberg.a")
        .arg("target/x86_64-apple-darwin/release/libswoirenberg.a")
        .status()
        .expect("Error running lipo")
        .success()
        .then_some(())
        .expect("Failed to create universal-apple-darwin module");

    // Create xcframework bundle using xcodebuild
    println!("post-build.rs: Bundling modules into framework");
    let _ = fs::remove_dir_all(".artifacts/Swoirenberg.xcframework");
    Command::new("xcodebuild")
        .arg("-create-xcframework")
        .args(&["-library", "target/universal-apple-darwin/release/libswoirenberg.a", "-headers", "../Swift/Sources/Bridge/CBridge/include"])
        .args(&["-library", "target/aarch64-apple-ios/release/libswoirenberg.a", "-headers", "../Swift/Sources/Bridge/CBridge/include"])
        .args(&["-output", ".artifacts/Swoirenberg.xcframework"])
        .status()
        .expect("Error running xcodebuild")
        .success()
        .then_some(())
        .expect("Failed to create framework bundle");

    // Zip the framework
    println!("post-build.rs: Zipping framework");
    Command::new("zip")
        .current_dir(".artifacts")
        .args(&["-X", "-9", "-r", "Swoirenberg.xcframework.zip", "Swoirenberg.xcframework"])
        .args(&["-i", "*.a", "-i", "*.plist", "-i", "*.h"])
        .status()
        .expect("Error running zip")
        .success()
        .then_some(())
        .expect("Failed to zip framework bundle");
    let file_path = env::current_dir()?.join(".artifacts/Swoirenberg.xcframework.zip");
    println!("post-build.rs: Created zipped framework at {}", file_path.to_str().unwrap());

    // Print the checksum of the zipped framework bundle
    let hash = format!("{:x}", Sha256::digest(&fs::read(file_path)?));
    println!("post-build.rs: Swoirenberg.xcframework.zip checksum is {}", hash);

    Ok(())
}
