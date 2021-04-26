//
//  DeviceTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 4/22/21.
//

@testable import Allie
import HealthKit
import XCTest

class DeviceTests: XCTestCase {
	let local = HKDevice.local()
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testConversion() throws {
		let chDevice = CHDevice(device: local)
		XCTAssertEqual(chDevice.name, local.name)
		XCTAssertEqual(chDevice.model, local.model)
		XCTAssertEqual(chDevice.udiDeviceIdentifier, local.udiDeviceIdentifier)
		XCTAssertEqual(chDevice.manufacturer, local.manufacturer)
		XCTAssertEqual(chDevice.firmwareVersion, local.firmwareVersion)
		XCTAssertEqual(chDevice.hardwareVersion, local.hardwareVersion)
		XCTAssertEqual(chDevice.localIdentifier, local.localIdentifier)
		XCTAssertEqual(chDevice.softwareVersion, local.softwareVersion)
	}
}
