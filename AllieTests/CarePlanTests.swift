//
//  CarePlanTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import Allie
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

	func testCarePlanRespnoseInsert() throws {
		let data = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(data)
		let decoder = CHJSONDecoder()
		let carePlanResponse = try decoder.decode(CHCarePlanResponse.self, from: data!)
		let careManager = CareManager.shared
		let expect = expectation(description: "CreateOrUpdate")
		careManager.process(carePlanResponse: carePlanResponse, forceReset: true, completion: { result in
			switch result {
			case .failure(let error):
				XCTFail(error.localizedDescription)
			case .success(let tasks):
				XCTAssertNotNil(careManager.patient)
				XCTAssertNotNil(careManager.patient?.uuid)
				expect.fulfill()
				ALog.info("did succeed \(tasks.count)")
			}
		})
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testCarePlanResponseUpdate() throws {
		let data = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(data)
		let decoder = CHJSONDecoder()
		let carePlanResponse = try decoder.decode(CHCarePlanResponse.self, from: data!)
		let careManager = CareManager.shared
		let expect = expectation(description: "CreateOrUpdate")
		careManager.process(carePlanResponse: carePlanResponse, completion: { result in
			switch result {
			case .failure(let error):
				XCTFail(error.localizedDescription)
			case .success:
				XCTAssertNotNil(careManager.patient)
				XCTAssertNotNil(careManager.patient?.uuid)
				expect.fulfill()
				ALog.info("did succeed")
			}
		})
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testCarePlanEncodeDecode() throws {
		let data = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(data)
		let decoder = CHJSONDecoder()
		let carePlanResponse = try decoder.decode(CHCarePlanResponse.self, from: data!)
		XCTAssertNotNil(carePlanResponse.tasks)
	}

	func carePlanDecode(string: String) throws -> CHCarePlan {
		let decoder = CHJSONDecoder()
		if let data = string.data(using: .utf8) {
			let carePlan = try decoder.decode(CHCarePlan.self, from: data)
			return carePlan
		} else {
			throw URLError(.cannotDecodeRawData)
		}
	}
}
