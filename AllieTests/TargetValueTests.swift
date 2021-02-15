//
//  TargetValueTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import Allie
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
		let decoder = CHJSONDecoder()
		if let data = dataString.data(using: .utf8) {
			let targetValue = try decoder.decode(OutcomeValue.self, from: data)
			XCTAssertEqual(targetValue.type, OCKOutcomeValueType.boolean, "invalid remote Id")
			XCTAssertEqual(targetValue.groupIdentifier, "", "invalid group Id")
			XCTAssertEqual(targetValue.timezone, TimeZone(secondsFromGMT: 0), "invalid timezone")
		} else {
			throw URLError(.cannotDecodeRawData)
		}
	}
}
