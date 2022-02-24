//
//  CloudDevicesTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 11/8/21.
//

@testable import Allie
import CodexFoundation
import CodexModel
import XCTest

class CloudDevicesTests: XCTestCase {
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testExample() throws {
		let downloaded = try AllieTests.loadTestData(fileName: "CloudDevices", withExtension: "json")
		let cloudDevices = try CHFJSONDecoder().decode(CMCloudDevices.self, from: downloaded)
		XCTAssertEqual(cloudDevices.devices.count, 2)
		XCTAssertEqual(cloudDevices.registrations.count, 1)
	}
}
