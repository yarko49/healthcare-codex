//
//  CarePlanTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import Allie
import Foundation
import XCTest

class CarePlanTests: XCTestCase {
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testCarePlanRespnoseInsert() throws {
		let data = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(data)
		let decoder = CHJSONDecoder()
		let carePlanResponse = try decoder.decode(CarePlanResponse.self, from: data!)
		let careManager = AppDelegate.careManager
		let expect = expectation(description: "CreateOrUpdate")
		careManager.createOrUpdate(carePlanResponse: carePlanResponse, forceReset: true, completion: { success in
			XCTAssertNotNil(careManager.patient)
			XCTAssertNotNil(careManager.patient?.uuid)
			if success {
				expect.fulfill()
			}
			ALog.info("did succeed \(success)")
		})
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testCarePlanResponseUpdate() throws {
		let data = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(data)
		let decoder = CHJSONDecoder()
		let carePlanResponse = try decoder.decode(CarePlanResponse.self, from: data!)
		let careManager = AppDelegate.careManager
		let expect = expectation(description: "CreateOrUpdate")
		careManager.createOrUpdate(carePlanResponse: carePlanResponse, completion: { success in
			XCTAssertNotNil(careManager.patient)
			XCTAssertNotNil(careManager.patient?.uuid)
			if success {
				expect.fulfill()
			}
			ALog.info("did succeed \(success)")
		})
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testCarePlanEncodeDecode() throws {
		let data = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(data)
		let decoder = CHJSONDecoder()
		let carePlanResponse = try decoder.decode(CarePlanResponse.self, from: data!)
		XCTAssertNotNil(carePlanResponse.tasks)
	}

	func carePlanDecode(string: String) throws -> CarePlan {
		let decoder = CHJSONDecoder()
		if let data = string.data(using: .utf8) {
			let carePlan = try decoder.decode(CarePlan.self, from: data)
			return carePlan
		} else {
			throw URLError(.cannotDecodeRawData)
		}
	}
}
