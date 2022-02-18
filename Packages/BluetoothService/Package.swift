// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "BluetoothService",
	platforms: [.iOS(.v14), .watchOS(.v7)],
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "BluetoothService",
			targets: ["BluetoothService"]
		),
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
		// .package(url: "https://github.com/PureSwift/Bluetooth.git", from: "5.0.0"),
		.package(name: "CodexFoundation", path: "../CodexFoundation"),
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "BluetoothService",
			dependencies: ["CodexFoundation"]
		),
		.testTarget(
			name: "BluetoothServiceTests",
			dependencies: ["BluetoothService", "CodexFoundation"]
		),
	]
)
