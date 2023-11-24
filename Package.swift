// swift-tools-version:5.9
//
// The `swift-tools-version` declares the minimum version of Swift required to
// build this package. Do not remove it.

import PackageDescription

let package = Package(
  name: "NordicDFU",
  platforms: [
    .macOS(.v10_14),
    .iOS(.v12),
    .watchOS(.v4),
    .tvOS(.v12)
  ],
  products: [
    .library(name: "NordicDFU", targets: ["NordicDFU"])
  ],
  dependencies: [
    .package(url: "https://github.com/weichsel/ZIPFoundation", exact: "0.9.16"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "NordicDFU",
      dependencies: ["ZIPFoundation"],
      path: "Library/",
      sources: ["Classes", "Assets"]
    ),
    // FIXME: Exclude this target for `watchOS` Simulator, because it fails to
    // compile in Xcode.
    .testTarget(
      name: "Hex2BinConverterTests",
      dependencies: ["NordicDFU"],
      path: "Test App/Tests/"
    )
  ],
  swiftLanguageVersions: [.v5]
)
