//
//  TargetValueTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import Allie
import CareKitStore
import CareModel
import CodexFoundation
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
		let decoder = CHFJSONDecoder()
		if let data = dataString.data(using: .utf8) {
			let targetValue = try decoder.decode(CHOutcomeValue.self, from: data)
			XCTAssertEqual(targetValue.type, OCKOutcomeValueType.boolean, "invalid remote Id")
		} else {
			throw URLError(.cannotDecodeRawData)
		}
	}

	func testTargetValueExtended() throws {
		let dataString =
			"""
			{
			    "groupIdentifier": "",
			    "remoteId": "",
			    "id": "",
			    "notes": null,
			    "asset": "",
			    "source": "",
			    "tags": null,
			    "userInfo": {
			        "category": "",
			        "detailViewText": "",
			        "detailViewCSS": "",
			        "detailViewHTML": "",
			        "detailViewImageLabel": "",
			        "detailViewURL": "",
			        "image": "",
			        "subtitle": "",
			        "logText": "",
			        "priority": ""
			    },
			    "createdDate": null,
			    "deletedDate": null,
			    "effectiveDate": null,
			    "updatedDate": null,
			    "index": 0,
			    "kind": "",
			    "units": "count",
			    "value": 200,
			    "type": "integer"
			}
			"""
		let decoder = CHFJSONDecoder()
		if let data = dataString.data(using: .utf8) {
			let targetValue = try decoder.decode(CHOutcomeValue.self, from: data)
			XCTAssertEqual(targetValue.type, OCKOutcomeValueType.integer, "invalid remote Id")
		} else {
			throw URLError(.cannotDecodeRawData)
		}
	}
}
