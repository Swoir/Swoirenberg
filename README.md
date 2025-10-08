# Swoirenberg

![Version](https://img.shields.io/badge/version-1.0.0--beta.14--1-darkviolet)
[![Noir](https://img.shields.io/badge/Noir-1.0.0--beta.14--1-darkviolet)](https://github.com/AztecProtocol/aztec-packages/tree/master/noir)
[![Swift 5](https://img.shields.io/badge/Swift-5-blue.svg)](https://developer.apple.com/swift/)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-green)](https://opensource.org/license/apache-2-0)

Swoirenberg is a Swift library for creating and verifying proofs using [Barretenberg](https://github.com/AztecProtocol/aztec-packages/tree/master/barretenberg), the default backend proving system used by [Noir](https://noir-lang.org).

### Architectures

- iOS with architectures: `arm64`
- macOS with architectures: `arm64`

## Installation

### Build

You don't have to use the pre-built binaries. You can build it locally on your trusted machine.

```
$ git clone https://github.com/Swoir/Swoirenberg.git
$ cd Swoirenberg
$ make
```

The result of the build process is located at `Frameworks/Swoirenberg.xcframework.zip`

## What is Swoirenberg.xcframework?

`Swoirenberg.xcframework` is distributed as a multiplatform XCFramework bundle. For more information check out the documentation [Distributing Binary Frameworks as Swift Packages](https://developer.apple.com/documentation/xcode/distributing-binary-frameworks-as-swift-packages)

## Authors

- [Bartosz Nowak / BartolomeoDiaz](https://github.com/Okm165)
- [Michael Elliot](https://x.com/michaelelliot)
- [Théo Madzou](https://x.com/madztheo)

## Contributing

Contributions are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License

Licensed under the Apache-2.0 License. See [LICENSE](./LICENSE) for more information.
