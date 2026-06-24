// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CxCarPlay",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "CxCarPlay", targets: ["CxCarPlay"]),
    ],
    dependencies: [
        .package(url: "https://github.com/neonindigo/Cx", branch: "master"),
    ],
    targets: [
        .target(
            name: "CxCarPlay",
            dependencies: [
                .product(name: "Cx", package: "Cx"),
            ]
        ),
        .testTarget(
            name: "CxCarPlayTests",
            dependencies: ["CxCarPlay"]
        ),
    ]
)
