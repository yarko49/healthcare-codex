//
//  TargetValueTests.swift
//  AlfrediOSTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import alfred_ios
import CareKitStore
import XCTest

class TargetValueTests: XCTestCase {
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testTargetValue() throws {
		let dataString =
			"""
			{
			    "id" : "",
			    "index" : 0,
			    "remoteId" : "",
			    "asset" : "",
			    "units" : "",
			    "source" : "",
			    "value" : true,
			    "type" : "boolean",
			    "groupIdentifier" : "",
			    "timezone" : 0,
			    "effectiveDate" : null,
			    "kind" : ""
			  }
			"""
		let decoder = AlfredJSONDecoder()
		if let data = dataString.data(using: .utf8) {
			let targetValue = try decoder.decode(OutcomeValue.self, from: data)
			XCTAssertEqual(targetValue.type, OCKOutcomeValueType.boolean, "invalid remote Id")
			XCTAssertEqual(targetValue.groupIdentifier, "", "invalid group Id")
			XCTAssertEqual(targetValue.timezone, TimeZone(secondsFromGMT: 0), "invalid timezone")
			XCTAssertNil(targetValue.effectiveDate)
		} else {
			throw URLError(.cannotDecodeRawData)
		}
	}

	func testPerformanceExample() throws {
		// This is an example of a performance test case.
		measure {
			// Put the code you want to measure the time of here.
		}
	}
}
