//
//  ObservationsConfigTest.swift
//  AllieTests
//
//  Created by Waqar Malik on 3/12/21.
//

@testable import Allie
import HKToFHIR
import ModelsR4
import XCTest

class ObservationsConfigTest: XCTestCase {
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testCreate() throws {
		let config = try? ObservationsConfig()
		XCTAssertNotNil(config)
		let heartRate = config?[code: "HKQuantityTypeIdentifierHeartRate"]
		XCTAssertNotNil(heartRate)

		let bloodPressure = config?[code: "HKCorrelationTypeIdentifierBloodPressure"]
		XCTAssertNotNil(bloodPressure)
	}
}
