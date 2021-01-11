//
//  ScheduleElementTests.swift
//  AlfredTests
//
//  Created by Waqar Malik on 1/10/21.
//

@testable import Alfred
import CareKitStore
import XCTest

class ScheduleElementTests: XCTestCase {
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testScheduleElement() throws {
		let data =
			"""
			{
			  "userInfo": {},
			  "custom": false,
			  "daily": true,
			  "weekly": false,
			  "weekday": 0,
			  "hour": 0,
			  "minutes": 0,
			  "duration": 0,
			  "interval": 0,
			  "text": "",
			  "start": null
			}
			"""
			.data(using: .utf8)
		XCTAssertNotNil(data)
		let scheduleElement = try JSONDecoder().decode(ScheduleElement.self, from: data!)
		let ockScheduleElement = OCKScheduleElement(scheduleElement: scheduleElement)
		XCTAssertEqual(ockScheduleElement.text, "")
	}
}
