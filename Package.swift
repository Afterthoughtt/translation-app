// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Interpreter",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "InterpreterCore", targets: ["InterpreterCore"]),
    ],
    targets: [
        .target(name: "InterpreterCore"),
        .testTarget(
            name: "InterpreterCoreTests",
            dependencies: ["InterpreterCore"]
        ),
    ]
)

