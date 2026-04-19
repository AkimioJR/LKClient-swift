// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LKClient",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
    .tvOS(.v17),
    .watchOS(.v10),
    .visionOS(.v1),
  ],
  products: [
    .library(name: "LKClient", targets: ["LKClient"]),
    .library(name: "LKEmoji", targets: ["LKEmoji"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "LKClient",
      dependencies: [],
      resources: [
        .process("Resources")
      ]
    ),
    .target(
      name: "LKEmoji",
      dependencies: []
    ),
    .testTarget(
      name: "LKEmojiTests",
      dependencies: ["LKEmoji"],
      resources: [
        .process("LKEmojiTest/Resources")
      ]
    ),
  ]
)
