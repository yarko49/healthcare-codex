//
//  CarePlanManagerTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 3/9/22.
//

@testable import Allie
import CareModel
import CodexFoundation
import XCTest

class CarePlanManagerTests: XCTestCase {
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testLoadPlan() async throws {
		let bundle = Bundle(for: CarePlanManagerTests.self)
		let data = try bundle.loadTestData(fileName: "MurariCarePlanResponse", withExtension: "json")
		let carePlanResponse = try CHFJSONDecoder().decode(CHCarePlanResponse.self, from: data)
		let manager = await CarePlanManager()
		await manager.process(carePlanResponse: carePlanResponse)
		let activeCarePlan = await manager.activeCarePlan
		XCTAssertNotNil(activeCarePlan)
		XCTAssertEqual(activeCarePlan!.id, "diabetesCarePlan")
	}
}
