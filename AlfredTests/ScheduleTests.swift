//
//  ScheduleTests.swift
//  AlfrediOSTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import Alfred
import CareKitStore
import Foundation
import XCTest

class ScheduleTests: XCTestCase {
	var testData: Data!
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		testData = AlfredTests.loadTestData(fileName: "SechduleA.json")
		XCTAssertNotNil(testData)
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testScheduleA() throws {
		let decoder = CHJSONDecoder()
		XCTAssertNotNil(testData)
		let schedule = try decoder.decode(ScheduleElement.self, from: testData)
		var startDate = DateFormatter.wholeDate.date(from: "2020-11-11T01:31:00.343Z")
		startDate = Calendar.current.startOfDay(for: startDate!)
		XCTAssertEqual(schedule.start, startDate!)
		let endDate = DateFormatter.wholeDateNoTimeZoneRequest.date(from: "2999-11-11T01:31:00Z")
		XCTAssertEqual(schedule.end, endDate!)
		XCTAssertEqual(schedule.weekly, false)
		XCTAssertEqual(schedule.daily, false)
		XCTAssertEqual(schedule.interval, 0.0)
		XCTAssertNotNil(schedule.targetValues)
		XCTAssertEqual(schedule.targetValues?.count, 3)
		XCTAssertEqual(schedule.duration, 0)
		XCTAssertEqual(schedule.minutes, 0)
		XCTAssertEqual(schedule.hour, 0)
		XCTAssertEqual(schedule.weekday, 0)
	}
}
