//
//  DateFormatterTests.swift
//  AlfrediOSTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import Alfred
import XCTest

class DateFormatterTests: XCTestCase {
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testISO8601Formatter() throws {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		let dateStrings: [String] = ["2020-11-11T01:31:00.343Z", "2999-11-11T01:31:00Z"]
		let dates = dateStrings.compactMap { (dateString) -> Date? in
			DateFormatter.wholeDateRequest.date(from: dateString) ?? DateFormatter.wholeDateNoTimeZoneRequest.date(from: dateString)
		}
		XCTAssertEqual(dates.count, 2)
	}
}
