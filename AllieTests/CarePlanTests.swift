//
//  CarePlanTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import Allie
import CodexFoundation
import Combine
import Foundation
import XCTest

class CarePlanTests: XCTestCase {
	var cancellables: Set<AnyCancellable> = []

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testCarePlanRespnoseInsert() async throws {
		let data = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(data)
		let decoder = CHFJSONDecoder()
		let carePlanResponse = try decoder.decode(CHCarePlanResponse.self, from: data!)
		let careManager = CareManager.shared
		let upodateCarePlanResponse = try await careManager.process(carePlanResponse: carePlanResponse)
		XCTAssertNotNil(careManager.patient)
		XCTAssertNotNil(careManager.patient?.uuid)
		XCTAssertEqual(careManager.patient?.uuid, upodateCarePlanResponse.patients.active.first?.uuid)
	}

	func testCarePlanEncodeDecode() throws {
		let data = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(data)
		let decoder = CHFJSONDecoder()
		let carePlanResponse = try decoder.decode(CHCarePlanResponse.self, from: data!)
		XCTAssertNotNil(carePlanResponse.tasks)
	}

	func carePlanDecode(string: String) throws -> CHCarePlan {
		let decoder = CHFJSONDecoder()
		if let data = string.data(using: .utf8) {
			let carePlan = try decoder.decode(CHCarePlan.self, from: data)
			return carePlan
		} else {
			throw URLError(.cannotDecodeRawData)
		}
	}

	func testNewCarePlan() throws {
		let data = AllieTests.loadTestData(fileName: "NewCarePlan.json")
		XCTAssertNotNil(data)
		let decoder = CHFJSONDecoder()
		let carePlanResponse = try decoder.decode(CHCarePlanResponse.self, from: data!)
		XCTAssertNotNil(carePlanResponse.tasks)
	}

	func testBadCarePlan() throws {
		let data = AllieTests.loadTestData(fileName: "BadCarePlan.json")
		XCTAssertNotNil(data)
		let decoder = CHFJSONDecoder()
		let carePlanResponse = try decoder.decode(CHCarePlanResponse.self, from: data!)
		XCTAssertNotNil(carePlanResponse.tasks)
	}
}
