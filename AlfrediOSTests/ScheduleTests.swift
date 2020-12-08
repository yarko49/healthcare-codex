//
//  ScheduleTests.swift
//  AlfrediOSTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import alfred_ios
import Foundation
import XCTest

class ScheduleTests: XCTestCase {
	var testData: Data!
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		testData = AlfrediOSTests.loadTestData(fileName: "SechduleA.json")
		XCTAssertNotNil(testData)
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testScheduleA() throws {
		let decoder = AlfredJSONDecoder()
		XCTAssertNotNil(testData)
		let schedule = try decoder.decode(Schedule.self, from: testData)
		let startDate = DateFormatter.wholeDate.date(from: "2020-11-11T01:31:00.343Z")
		XCTAssertEqual(schedule.startDate, startDate!)
		let endDate = DateFormatter.wholeDateNoTimeZoneRequest.date(from: "2999-11-11T01:31:00Z")
		XCTAssertEqual(schedule.endDate, endDate!)
		XCTAssertEqual(schedule.isWeekly, false)
		XCTAssertEqual(schedule.isDaily, false)
		XCTAssertEqual(schedule.interval, 28800)
		XCTAssertNotNil(schedule.targetValues)
		XCTAssertEqual(schedule.targetValues?.count, 3)
		XCTAssertEqual(schedule.duration, 0)
		XCTAssertEqual(schedule.minutes, 0)
		XCTAssertEqual(schedule.hour, 0)
		XCTAssertEqual(schedule.weekday, 0)
	}

	func testPerformanceExample() throws {
		// This is an example of a performance test case.
		measure {
			// Put the code you want to measure the time of here.
		}
	}
}
