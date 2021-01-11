//
//  TaskTests.swift
//  AlfrediOSTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import Alfred
import CareKitStore
import XCTest

class TaskTests: XCTestCase {
	var testData: Data!

	override func setUpWithError() throws {
		testData = AlfredTests.loadTestData(fileName: "TaskB2.json")
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

	func testTask() throws {
		let taskData =
			"""
			{
			  "remoteId": "09e01234-fa95-51f0-b4a8-3c5cb815135b",
			  "id": "DMSymptomsFatigue",
			  "asset": "",
			  "source": "",
			  "timezone": 0,
			  "userInfo": {},
			  "effectiveDate": null,
			  "title": "Fatigue",
			  "schedules": {
			    "scheduleA": {
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
			  },
			  "carePlanId": "defaultDiabetesCarePlan",
			  "instructions": "Report symptoms of Fatigue",
			  "impactsAdherence": false,
			  "groupIdentifier": "LOG"
			}
			"""
			.data(using: .utf8)

		XCTAssertNotNil(taskData)
		let task = try JSONDecoder().decode(Task.self, from: taskData!)
		let ockTask = OCKTask(task: task)
		XCTAssertEqual(ockTask.id, "DMSymptomsFatigue")
	}

	func testAllTasks() throws {
		let data = AlfredTests.loadTestData(fileName: "DefaultDiabetesCarePlan.json")
		XCTAssertNotNil(data)
		let decoder = AlfredJSONDecoder()
		let carePlanResponse = try decoder.decode(CarePlanResponse.self, from: data!)
		let allTasks = carePlanResponse.allTasks
		XCTAssertNotEqual(allTasks.count, 0)
		let ockTasks = allTasks.map { (task) -> OCKTask in
			OCKTask(task: task)
		}

		XCTAssertEqual(ockTasks.count, allTasks.count)
	}
}
