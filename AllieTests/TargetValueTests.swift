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
			    "userInfo": {},
			    "effectiveDate" : null,
			    "kind" : ""
			  }
			"""
		let decoder = CHJSONDecoder()
		if let data = dataString.data(using: .utf8) {
			let targetValue = try decoder.decode(OutcomeValue.self, from: data)
			XCTAssertEqual(targetValue.type, OCKOutcomeValueType.boolean, "invalid remote Id")
		} else {
			throw URLError(.cannotDecodeRawData)
		}
	}
}
