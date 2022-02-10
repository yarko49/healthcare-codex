// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "ClientAPI",
	platforms: [.iOS(.v13), .watchOS(.v6)],
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "ClientAPI",
			targets: ["ClientAPI"]
		),
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
		.package(name: "WebService", url: "https://github.com/wmalloc/WebService.git", .upToNextMajor(from: "0.2.1")),
		.package(name: "FHIRModels", url: "https://github.com/apple/FHIRModels.git", .upToNextMajor(from: "0.1.0")),
		.package(name: "CodexModel", path: "../CodexModel"),
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "ClientAPI",
			dependencies: ["WebService", "CodexModel",
			               .product(name: "ModelsR4", package: "FHIRModels")]
		),
		.testTarget(
			name: "ClientAPITests",
			dependencies: ["ClientAPI"]
		),
	]
)
