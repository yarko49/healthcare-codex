//
//  TasksTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 12/7/20.
//

@testable import Allie
import HealthKit
import XCTest

class TasksTests: XCTestCase {
	var carePlanResponse: Data!
	var carePlan: [String: Any]!

	override func setUpWithError() throws {
		carePlanResponse = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(carePlanResponse)
		carePlan = try JSONSerialization.jsonObject(with: carePlanResponse, options: .allowFragments) as? [String: Any]
		XCTAssertNotNil(carePlan)
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testTasks() throws {
		let tasksDictionary = carePlan["tasks"] as? [[String: Any]]
		XCTAssertNotNil(tasksDictionary)
		let data = try JSONSerialization.data(withJSONObject: tasksDictionary!, options: .prettyPrinted)
		let decoder = CHJSONDecoder()
		do {
			let tasks = try decoder.decode([Task].self, from: data)
			XCTAssertEqual(tasks.count, 9)
		} catch {
			ALog.error("\(error.localizedDescription)")
		}
	}

	func testHealthKitIdentifier() throws {
		let stepCount: HKQuantityTypeIdentifier = .stepCount
		let identifier = HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifier" + "stepCount".capitalizingFirstLetter())
		XCTAssertEqual(stepCount, identifier)
		let sampleType = HKSampleType.quantityType(forIdentifier: identifier)
		XCTAssertNotNil(sampleType)
	}
}
