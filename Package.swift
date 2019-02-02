// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "chatter",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc"),
        .package(url: "https://github.com/skelpo/JWTVapor.git", from: "0.12.0"),
        .package(url: "https://github.com/skelpo/JWTMiddleware.git", from: "0.9.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "JWTVapor", "JWTMiddleware"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)

