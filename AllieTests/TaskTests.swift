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
		let task = try decoder.decode(CHTask.self, from: testData!)
		XCTAssertEqual(task.id, "XXXX-SOME-UUID-ZZZZ")
		XCTAssertEqual(task.remoteId, "XXXX-SOME-UUID-ZZZZ")
		XCTAssertEqual(task.title, "custom-3x-daily-finite-grid")
		XCTAssertNotNil(task.scheduleElements)
		XCTAssertEqual(task.scheduleElements.count, 1)
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
		let task = try JSONDecoder().decode(CHTask.self, from: taskData!)
		let ockTask = OCKTask(task: task)
		XCTAssertEqual(ockTask.id, "09e01234-fa95-51f0-b4a8-3c5cb815135b")
	}

	func testAllTasks() throws {
		let data = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(data)
		let decoder = CHJSONDecoder()
		let carePlanResponse = try decoder.decode(CHCarePlanResponse.self, from: data!)
		let allTasks = carePlanResponse.tasks
		XCTAssertNotEqual(allTasks.count, 0)
		let ockTasks = allTasks.map { task -> OCKTask in
			OCKTask(task: task)
		}

		XCTAssertEqual(ockTasks.count, allTasks.count)
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

	func testValueAndType() throws {
		let dataString = """
		    {
		      "groupIdentifier": "LOG",
		      "remoteId": "ljWpJ9ESPRrAlbaff9SZ",
		      "id": "",
		      "notes": null,
		      "asset": "",
		      "source": "",
		      "tags": null,
		      "timezone": {
		        "abbreviation": "",
		        "identifier": ""
		      },
		      "userInfo": {
		        "category": "medications",
		        "detailViewText": "",
		        "detailViewCSS": "",
		        "detailViewHTML": "",
		        "detailViewImageLabel": "",
		        "detailViewURL": "",
		        "image": "",
		        "subtitle": "",
		        "logText": "",
		        "priority": "0"
		      },
		      "createdDate": "2021-04-22T12:22:16.222536Z",
		      "deletedDate": "9999-01-01T00:00:00Z",
		      "effectiveDate": "2021-04-22T12:22:16.222536Z",
		      "updatedDate": "2021-04-27T23:43:34.164043Z",
		      "title": "test org med",
		      "schedules": {
		        "scheduleA": {
		          "custom": false,
		          "daily": false,
		          "weekly": true,
		          "weekday": 0,
		          "hour": 0,
		          "minutes": 0,
		          "duration": 0,
		          "interval": 0,
		          "text": "",
		          "targetValues": [
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
		          ],
		          "start": "2021-04-22T12:15:38.96Z",
		          "end": "2021-04-29T12:15:38.96Z"
		        }
		      },
		      "carePlanId": "defaultCarePlan",
		      "healthKitLinkage": null,
		      "instructions": "",
		      "impactsAdherence": false,
		      "versions": null
		    }
		"""
		let data = dataString.data(using: .utf8)
		XCTAssertNotNil(data)
		let task = try CHJSONDecoder().decode(CHTask.self, from: data!)
		XCTAssertNotNil(task)
		let ockTask = OCKTask(task: task)
		XCTAssertNotNil(ockTask)
	}

	func testMedications() throws {
		let dataString = """
		{
		    "groupIdentifier": "LOG",
		    "remoteId": "yULAvxCDijVbz5gGGbR0",
		    "id": "",
		    "notes": null,
		    "asset": "",
		    "source": "HealthcareOrganization/CodexPilotHealthcare-3kuss/Task/yULAvxCDijVbz5gGGbR0",
		    "tags": null,
		    "timezone": {
		        "abbreviation": "",
		        "identifier": ""
		    },
		    "userInfo": {
		        "category": "medications",
		        "detailViewAsset": "",
		        "detailViewText": "",
		        "detailViewCSS": "",
		        "detailViewHTML": "",
		        "detailViewImageLabel": "",
		        "detailViewURL": "",
		        "image": "",
		        "subtitle": "",
		        "logText": "",
		        "priority": "0"
		    },
		    "createdDate": "2021-05-13T17:24:50Z",
		    "deletedDate": "9999-01-01T00:00:00Z",
		    "effectiveDate": "2021-05-13T17:24:50Z",
		    "updatedDate": "2021-05-14T02:53:49Z",
		    "title": "Alpha Beta",
		    "schedules": [
		        {
		            "custom": false,
		            "daily": true,
		            "weekly": false,
		            "weekday": 0,
		            "hour": 0,
		            "minutes": 0,
		            "duration": 0,
		            "interval": 604800,
		            "text": "",
		            "targetValues": [
		                {
		                    "groupIdentifier": "",
		                    "remoteId": "",
		                    "id": "",
		                    "notes": null,
		                    "asset": "",
		                    "source": "",
		                    "tags": null,
		                    "timezone": {
		                        "abbreviation": "",
		                        "identifier": ""
		                    },
		                    "createdDate": null,
		                    "deletedDate": null,
		                    "effectiveDate": null,
		                    "updatedDate": null,
		                    "index": 0,
		                    "kind": "",
		                    "units": "count",
		                    "value": 100,
		                    "type": "integer",
		                    "userInfo": null
		                }
		            ],
		            "start": "2021-05-13T17:24:03.921Z",
		            "end": "2021-05-13T17:24:03.921Z"
		        }
		    ],
		    "carePlanId": "",
		    "healthKitLinkage": null,
		    "instructions": "Take with water",
		    "impactsAdherence": false,
		    "versions": null
		}
		"""
		let data = dataString.data(using: .utf8)
		XCTAssertNotNil(data)
		let task = try CHJSONDecoder().decode(CHTask.self, from: data!)
		XCTAssertNotNil(task)
		let ockTask = OCKTask(task: task)
		XCTAssertNotNil(ockTask)
	}

	func testActivityTask() throws {
		let testData = AllieTests.loadTestData(fileName: "ActivityTask.json")
		XCTAssertNotNil(testData)
		let task = try CHJSONDecoder().decode(CHTask.self, from: testData!)
		XCTAssertNotNil(task)
		let ockTask = task.ockTask
		XCTAssertNotNil(ockTask)
		ALog.info("\(ockTask)")
	}

	func testLinksTask() throws {
		let taskData = """
		    {
		    "groupIdentifier": "LINK",
		    "remoteId": "education-links-uc-health",
		    "id": "",
		    "source": "HealthcareOrganization/Demo-Organization-hmbj3/CarePlan/defaultCarePlan/Task/education-links-uc-health",
		    "userInfo": {
		    "category": "links",
		    "priority": "5"
		    },
		    "createdDate": "2021-08-05T18:53:43Z",
		    "deletedDate": "9999-01-01T00:00:00Z",
		    "effectiveDate": "2021-08-05T18:53:43Z",
		    "updatedDate": "2021-08-09T01:23:09Z",
		    "title": "Links",
		    "schedules": [
		    {
		    "custom": false,
		    "daily": true,
		    "weekly": false
		    }
		    ],
		    "carePlanId": "defaultCarePlan",
		    "instructions": "Helpful links",
		    "impactsAdherence": false,
		    "links": [
		    {
		    "url": "https://www.uchealth.org/",
		    "title": "UCHealth",
		    "type": "url"
		    },
		    {
		    "title": "UCHealth Hospital Address",
		    "type": "location",
		    "latitude": "39.742332",
		    "longitude": "-104.841487"
		    },
		    {
		    "title": "Email Support",
		    "type": "email",
		    "email": "support@codexhealth.com"
		    }
		    ]
		    }
		""".data(using: .utf8)
		XCTAssertNotNil(testData)
		do {
			let decode = try CHJSONDecoder().decode(CHTask.self, from: taskData!)
			let links = decode.links
			XCTAssertNotNil(links)
			let ockTask = OCKTask(task: decode)
			XCTAssertNotNil(ockTask)
			let ockLinks = ockTask.links
			XCTAssertNotNil(ockLinks)
			let linkItems = ockTask.linkItems
			XCTAssertNotNil(linkItems)
		} catch {
			ALog.error("\(error.localizedDescription)")
		}
	}
}
