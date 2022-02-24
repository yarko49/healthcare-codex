//
//  ScheduleTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import Allie
import CareKitStore
import CodexFoundation
import Foundation
import XCTest

class ScheduleTests: XCTestCase {
	var testData: Data!
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		testData = AllieTests.loadTestData(fileName: "SechduleA.json")
		XCTAssertNotNil(testData)
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testScheduleA() throws {
		let decoder = CHFJSONDecoder()
		XCTAssertNotNil(testData)
		let schedule = try decoder.decode(CHScheduleElement.self, from: testData)
		var startDate = DateFormatter.wholeDate.date(from: "2020-11-11T01:31:00.343Z")
		startDate = Calendar.current.startOfDay(for: startDate!)
		XCTAssertEqual(schedule.start, startDate!)
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

	func testWeeklyTask() throws {
		let data = """
		 {
		      "groupIdentifier": "SIMPLE",
		      "remoteId": "medications-actos",
		      "id": "",
		      "timezone": {},
		      "userInfo": {
		        "category": "medications",
		        "priority": "0"
		      },
		      "createdDate": "2021-08-05T18:53:41Z",
		      "deletedDate": "9999-01-01T00:00:00Z",
		      "effectiveDate": "2021-08-05T18:53:41Z",
		      "updatedDate": "2021-11-09T07:11:39Z",
		      "title": "Actos",
		      "schedules": [
		        {
		          "custom": false,
		          "daily": false,
		          "weekly": true,
		          "weekday": 1,
		          "targetValues": [
		            {
		              "groupIdentifier": "",
		              "id": "",
		              "kind": "dosage",
		              "units": "mg",
		              "value": 10,
		              "type": "double"
		            }
		          ],
		          "start": "2021-11-09T07:10:57.104Z"
		        }
		      ],
		      "carePlanId": "defaultCarePlan",
		      "instructions": "Monitoring daily Actos dosage",
		      "impactsAdherence": true
		    }
		""".data(using: .utf8)

		XCTAssertNotNil(data)
		let task = try CHFJSONDecoder().decode(CHTask.self, from: data!)
		XCTAssertNotNil(task.schedule)
		let ockTask = OCKTask(task: task)
		XCTAssertNotNil(ockTask)
		XCTAssertNotNil(ockTask.schedule)
		let date = Date()
		let calendar = Calendar.current
		let yesterday = calendar.date(byAdding: .day, value: -1, to: date)
		let isValidToday = ockTask.schedule.exists(onDay: date)
		let isValidYesterday = ockTask.schedule.exists(onDay: yesterday!)
		XCTAssertTrue(isValidToday)
		XCTAssertFalse(isValidYesterday)
	}
}
