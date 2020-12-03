//
//  DateFormatterTests.swift
//  AlfrediOSTests
//
//  Created by Waqar Malik on 11/26/20.
//

@testable import alfred_ios
import Foundation
import XCTest

class DateFormatterTests: XCTestCase {
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testDateFormatter() throws {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		let dateString = "2020-11-11T01:31:00.343Z"
		let formatter = DateFormatter.carePlanFormatter
		let date = formatter.date(from: dateString)
		XCTAssertNotNil(date, "Uable to convert date string, formatter invalid")
	}

	func testPerformanceExample() throws {
		// This is an example of a performance test case.
		measure {
			// Put the code you want to measure the time of here.
		}
	}
}
