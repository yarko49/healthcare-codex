//
//  TaskTests.swift
//  AlfrediOSTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import alfred_ios
import XCTest

class TaskTests: XCTestCase {
	var testData: Data?

	override func setUpWithError() throws {
		testData = AlfrediOSTests.loadTestData(fileName: "TaskB2.json")
		XCTAssertNotNil(testData)
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		testData = nil
	}

	func testTaskB2() throws {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(DateFormatter.wholeDateRequest)
		let task = try decoder.decode(Task.self, from: testData!)
		XCTAssertNotNil(task)
	}

	func testPerformanceExample() throws {
		// This is an example of a performance test case.
		measure {
			// Put the code you want to measure the time of here.
		}
	}
}
