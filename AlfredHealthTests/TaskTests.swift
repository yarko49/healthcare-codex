//
//  TaskTests.swift
//  AlfrediOSTests
//
//  Created by Waqar Malik on 12/6/20.
//

import AlfredCore
@testable import AlfredHealth
import XCTest

class TaskTests: XCTestCase {
	var testData: Data!

	override func setUpWithError() throws {
		testData = AlfredHealthTests.loadTestData(fileName: "TaskB2.json")
		XCTAssertNotNil(testData)
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		testData = nil
	}

	func testTaskB2() throws {
		let decoder = AlfredJSONDecoder()
		XCTAssertNotNil(testData)
		let task = try decoder.decode(Task.self, from: testData!)
		let startDate = AlfredHealthTests.wholeDate.date(from: "2020-11-11T01:31:00.343Z")
		XCTAssertEqual(task.effectiveDate, startDate!)
		XCTAssertEqual(task.id, "TaskB2")
		XCTAssertEqual(task.remoteId, "XXXX-SOME-UUID-ZZZZ")
		XCTAssertEqual(task.title, "custom-3x-daily-finite-grid")
		XCTAssertNotNil(task.schedules)
		XCTAssertEqual(task.schedules?.count, 1)
		XCTAssertEqual(task.groupIdentifier, "GRID")
		XCTAssertEqual(task.timezone, TimeZone(secondsFromGMT: 0))
		XCTAssertEqual(task.instructions, "3x daily instructions")
		XCTAssertEqual(task.impactsAdherence, true)
	}

	func testPerformanceExample() throws {
		// This is an example of a performance test case.
		measure {
			// Put the code you want to measure the time of here.
		}
	}
}
