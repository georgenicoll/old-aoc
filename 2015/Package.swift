// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "2015",
    products: [
        .library(name: "Core", targets: ["Core"]),

        .executable(name: "Day1", targets: ["Day1"]),
        .executable(name: "Day2", targets: ["Day2"]),
        .executable(name: "Day3", targets: ["Day3"]),
        .executable(name: "Day4", targets: ["Day4"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "Core"),

        .executableTarget(name: "Day1", dependencies: ["Core"], exclude: ["Files/"]),
        .executableTarget(name: "Day2", dependencies: ["Core"], exclude: ["Files/"]),
        .executableTarget(name: "Day3", dependencies: ["Core"], exclude: ["Files/"]),
        .executableTarget(name: "Day4", dependencies: [
            "Core",
            .product(name: "Crypto", package: "swift-crypto")
        ], exclude: ["Files/"]),
    ]
)
