//
//  TasksTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 12/7/20.
//

@testable import Allie
import CareKitStore
import CareModel
import CodexFoundation
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
		let decoder = CHFJSONDecoder()
		let tasks = try decoder.decode([CHTask].self, from: data)
		XCTAssertEqual(tasks.count, 10)
	}

	func testHealthKitIdentifier() throws {
		let stepCount: HKQuantityTypeIdentifier = .stepCount
		let identifier = HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifier" + "stepCount".capitalizingFirstLetter())
		XCTAssertEqual(stepCount, identifier)
		let sampleType = HKSampleType.quantityType(forIdentifier: identifier)
		XCTAssertNotNil(sampleType)
	}

	func testNewTasksDecode() throws {
		let tasksData = AllieTests.loadTestData(fileName: "NewTasks.json")
		XCTAssertNotNil(tasksData)
		let decoder = CHFJSONDecoder()
		do {
			let carePlanResponse = try decoder.decode(CHCarePlanResponse.self, from: tasksData!)
			XCTAssertNotNil(carePlanResponse.faultyTasks, "Missing faulty tasks")
			ALog.info("\(carePlanResponse.tasks.count)")
			ALog.info("\(String(describing: carePlanResponse.faultyTasks))")
		} catch {
			XCTFail("Unable to decode the data")
		}
	}

	func testActosTask() throws {
		let tasksData = AllieTests.loadTestData(fileName: "Actos.json")
		XCTAssertNotNil(tasksData)
		let decoder = CHFJSONDecoder()
		let task = try decoder.decode(CHTask.self, from: tasksData!)
		XCTAssertNotNil(task, "Missing faulty tasks")
		ALog.info("\(String(describing: task.id))")
		ALog.info("\(String(describing: task.groupIdentifier))")

		let ockTask = OCKTask(task: task)
		XCTAssertEqual("GRID", ockTask.groupIdentifier)
		XCTAssertEqual(task.scheduleElements.count, 2)
	}
}
