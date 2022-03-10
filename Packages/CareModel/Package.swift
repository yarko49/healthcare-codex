// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "CareModel",
	platforms: [.iOS(.v14), .watchOS(.v7)],
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(name: "CareModel", targets: ["CareModel"]),
	],
	dependencies: [
		.package(name: "CareKit", path: "../../../CareKit"),
		.package(name: "CodexModel", path: "../CodexModel"),
		.package(name: "BluetoothService", path: "../BluetoothService"),
		.package(name: "CodexFoundation", path: "../CodexFoundation"),
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "CareModel",
			dependencies: [.product(name: "CareKitStore", package: "CareKit"),
			               .product(name: "CareKitUI", package: "CareKit"),
			               "CodexModel", "BluetoothService", "CodexFoundation"]
		),
		.testTarget(name: "CareModelTests", dependencies: ["CareModel"]),
	]
)
