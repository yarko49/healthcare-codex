//
//  HealthKitToCareKitTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 10/5/21.
//

@testable import Allie
import CareKitStore
import HealthKit
import XCTest

class HealthKitToCareKitTests: XCTestCase {
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testBloodGlusoseConversion() throws {
		let now = Date()
		let date = now.advanced(by: -(24 * 60 * 60))
		ALog.info("Date \(date)", metadata: nil)
		let task = try healthKitTask()
		let sample = HKDiscreteQuantitySample(bloodGlucose: 120.0, startDate: date, mealTime: .postprandial)
		let outcome = CHOutcome(sample: sample, task: task, carePlanId: "defaultCarePlan")
		XCTAssertEqual(date, sample.startDate)
		XCTAssertEqual(date, sample.endDate)
		XCTAssertEqual(date, outcome?.createdDate)
		XCTAssertEqual(date, outcome?.startDate)
		XCTAssertEqual(date, outcome?.endDate)
		XCTAssertNotEqual(date, outcome?.updatedDate)
		let outcomeValue = outcome?.values.first
		XCTAssertNotNil(outcomeValue)
		XCTAssertEqual(outcomeValue?.kind, "postprandial")
		XCTAssertEqual(outcomeValue?.type.rawValue, "double")
		XCTAssertEqual(date, outcomeValue?.createdDate)
		XCTAssertEqual(outcomeValue?.doubleValue, 120.0)
	}

	func healthKitTask() throws -> OCKHealthKitTask {
		let taskData = """
		        {
		            "carePlanId": "defaultCarePlan",
		            "createdDate": "2021-08-05T18:53:43Z",
		            "deletedDate": "9999-01-01T00:00:00Z",
		            "effectiveDate": "2021-08-05T18:53:43Z",
		            "groupIdentifier": "LABELED_VALUE",
		            "healthKitLinkage": {
		                "quantityIdentifier": "bloodGlucose",
		                "quantitytype": "discrete",
		                "unit": "mg/dl"
		            },
		            "id": "",
		            "impactsAdherence": true,
		            "instructions": "Monitor daily glucose levels",
		            "remoteId": "measurements-glucose-levels",
		            "schedules": [
		                {
		                    "custom": false,
		                    "daily": true,
		                    "targetValues": [
		                        {
		                            "groupIdentifier": "",
		                            "id": "",
		                            "kind": "bloodGlucose",
		                            "type": "integer",
		                            "units": "mg/dL",
		                            "value": 140
		                        },
		                        {
		                            "groupIdentifier": "",
		                            "id": "",
		                            "kind": "noprandial",
		                            "type": "integer",
		                            "units": "",
		                            "value": 0
		                        },
		                        {
		                            "groupIdentifier": "",
		                            "id": "",
		                            "kind": "preprandial",
		                            "type": "integer",
		                            "units": "",
		                            "value": 1
		                        },
		                        {
		                            "groupIdentifier": "",
		                            "id": "",
		                            "kind": "postprandial",
		                            "type": "integer",
		                            "units": "",
		                            "value": 2
		                        }
		                    ],
		                    "weekly": false
		                }
		            ],
		            "source": "HealthcareOrganization/Demo-Organization-hmbj3/CarePlan/defaultCarePlan/Task/measurements-glucose-levels",
		            "title": "Glucose Levels",
		            "updatedDate": "2021-09-30T20:03:04Z",
		            "userInfo": {
		                "category": "measurements",
		                "priority": "0"
		            }
		        }
		""".data(using: .utf8)
		let decoder = CHJSONDecoder()
		let task = try decoder.decode(CHTask.self, from: taskData!)
		let ockHealthTask = OCKHealthKitTask(task: task)
		return ockHealthTask
	}
}
