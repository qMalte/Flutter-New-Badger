// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "flutter_new_badger",
    platforms: [
        .macOS("10.14")
    ],
    products: [
        .library(name: "flutter_new_badger", targets: ["flutter_new_badger"])
    ],
    targets: [
        .target(
            name: "flutter_new_badger",
            path: "Sources/flutter_new_badger"
        )
    ]
)
