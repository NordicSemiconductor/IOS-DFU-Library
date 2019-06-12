// swift-tools-version:5.0
//
// The `swift-tools-version` declares the minimum version of Swift required to
// build this package. Do not remove it.

import PackageDescription

let package = Package(
  name: "DFULibrary",
  platforms: [
    .macOS(.v10_14),
    .iOS(.v9)
  ],
  products: [
    .library(name: "DFULibrary", targets: ["DFULibrary"]),
    .library(name: "Hex2BinConverter", targets: ["Hex2BinConverter"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/weichsel/ZIPFoundation/",
      .upToNextMajor(from: "0.9.9")
    )
  ],
  targets: [
    .target(
      name: "Hex2BinConverter",
      path: "iOSDFULibrary/Classes/Utilities/HexToBinConverter/"
    ),
    .target(
      name: "DFULibrary",
      dependencies: ["Hex2BinConverter", "ZIPFoundation"],
      path: "iOSDFULibrary/Classes/",
      exclude: ["Utilities/HexToBinConverter/"]
    )
  ],
  swiftLanguageVersions: [.v5]
)
