//
//  TasksTests.swift
//  AlfrediOSTests
//
//  Created by Waqar Malik on 12/7/20.
//

import AlfredCore
@testable import AlfredHealth
import XCTest

class TasksTests: XCTestCase {
	var carePlanResponse: Data!
	var carePlan: [String: Any]!

	override func setUpWithError() throws {
		carePlanResponse = AlfredHealthTests.loadTestData(fileName: "ValueSpaceResponse.json")
		XCTAssertNotNil(carePlanResponse)
		carePlan = try JSONSerialization.jsonObject(with: carePlanResponse, options: .allowFragments) as? [String: Any]
		XCTAssertNotNil(carePlan)
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testTasks() throws {
		let tasksDictionary = carePlan["tasks"] as? [String: Any]
		XCTAssertNotNil(tasksDictionary)
		let data = try JSONSerialization.data(withJSONObject: tasksDictionary!, options: .prettyPrinted)
		let decoder = AlfredJSONDecoder()
		let tasks = try decoder.decode([String: Tasks].self, from: data)
		XCTAssertEqual(tasks.count, 2)
	}

	func testPerformanceExample() throws {
		// This is an example of a performance test case.
		measure {
			// Put the code you want to measure the time of here.
		}
	}
}
