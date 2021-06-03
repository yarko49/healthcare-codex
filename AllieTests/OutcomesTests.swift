//
//  OutcomesTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 5/3/21.
//

@testable import Allie
import CareKitStore
import XCTest

class OutcomesTests: XCTestCase {
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testOutcomes1() throws {
		let data = AllieTests.loadTestData(fileName: "Outcomes1.json")
		XCTAssertNotNil(data)
		let decoder = CHJSONDecoder()
		let carePlanResponse = try decoder.decode(CarePlanResponse.self, from: data!)
		XCTAssertEqual(carePlanResponse.outcomes.count, 43)
	}

	func testOutcomes2() throws {
		let data = AllieTests.loadTestData(fileName: "Outcomes2.json")
		XCTAssertNotNil(data)
		let decoder = CHJSONDecoder()
		let carePlanResponse = try decoder.decode(CarePlanResponse.self, from: data!)
		XCTAssertEqual(carePlanResponse.outcomes.count, 43)
	}
}
