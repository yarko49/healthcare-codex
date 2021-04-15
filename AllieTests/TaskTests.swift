//
//  TaskTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import Allie
import CareKitStore
import XCTest

class TaskTests: XCTestCase {
	var testData: Data!

	override func setUpWithError() throws {
		testData = AllieTests.loadTestData(fileName: "TaskB2.json")
		XCTAssertNotNil(testData)
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		testData = nil
	}

	func testTaskB2() throws {
		let decoder = CHJSONDecoder()
		XCTAssertNotNil(testData)
		let task = try decoder.decode(Task.self, from: testData!)
		XCTAssertEqual(task.id, "TaskB2")
		XCTAssertEqual(task.remoteId, "XXXX-SOME-UUID-ZZZZ")
		XCTAssertEqual(task.title, "custom-3x-daily-finite-grid")
		XCTAssertNotNil(task.schedules)
		XCTAssertEqual(task.schedules?.count, 1)
		XCTAssertEqual(task.groupIdentifier, "GRID")
		XCTAssertEqual(task.timezone, TimeZone(identifier: "America/Los_Angeles"))
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
		let data = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(data)
		let decoder = CHJSONDecoder()
		let carePlanResponse = try decoder.decode(CarePlanResponse.self, from: data!)
		let allTasks = carePlanResponse.tasks
		XCTAssertNotEqual(allTasks.count, 0)
		let ockTasks = allTasks.map { (task) -> OCKTask in
			OCKTask(task: task)
		}

		XCTAssertEqual(ockTasks.count, allTasks.count)
	}

	func testLinkTask() throws {
		let taskString = """
		{
		  "remoteId": "2b23a7bd-0507-516a-84d5-f3fee2d1addd",
		  "id": "Link",
		  "asset": "",
		  "source": "",
		  "timezone": 0,
		  "userInfo": {
		    "linkURL0": "https://med.stanford.edu/",
		    "linkURLTitle0": "Stanford Medicine",
		    "linkLocation0": "37.4275,122.1697",
		    "linkLocationTitle0": "Stanford Address",
		    "linkEmail0": "support@codexhealth.com",
		    "linkEmailTitle0": "Email Support"
		  },
		  "effectiveDate": "2020-11-11T01:31:00.343Z",
		  "title": "Links",
		  "schedules": {
		    "daily": {
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
		  "instructions": "Helpful links",
		  "impactsAdherence": false,
		  "groupIdentifier": "LINK"
		}
		"""
		let data = taskString.data(using: .utf8)
		XCTAssertNoThrow(data)
		let task = try CHJSONDecoder().decode(Task.self, from: data!)
		let ocTask = OCKTask(task: task)
		let linkItems = ocTask.linkItems
		XCTAssertNotNil(linkItems)
		XCTAssertEqual(linkItems?.count, 3)
	}

	func testScheduleElementsSorting() throws {
//		let data = CareManager.sampleResponse
//		let task = data.tasks["FoodDiaryRecall2"]
//		XCTAssertNotNil(task)
//		let sortedElements = task?.sortedScheduleElements
//		XCTAssertEqual(sortedElements?.count, 3)
//		XCTAssertEqual(sortedElements?[0].hour, 8)
//		XCTAssertEqual(sortedElements?[1].hour, 12)
//		XCTAssertEqual(sortedElements?[2].hour, 18)
	}
}
