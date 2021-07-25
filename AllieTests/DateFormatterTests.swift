//
//  DateFormatterTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import Allie
import XCTest

class DateFormatterTests: XCTestCase {
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testRFC3339Formatter() throws {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		let dateStrings: [String] = ["2020-11-11T01:31:00.343Z", "2999-11-11T01:31:00Z", "2006-01-02T15:04:05Z07:00", "1969-12-31T16:00:00Z"]
		let dates = dateStrings.compactMap { dateString -> Date? in
			DateFormatter.wholeDateRequest.date(from: dateString) ?? DateFormatter.wholeDateNoTimeZoneRequest.date(from: dateString)
		}
		XCTAssertEqual(dates.count, 3)
	}

	func testISO8601Formatter() throws {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		let dateStrings: [String] = ["2020-11-11T01:31:00.343Z", "2999-11-11T01:31:00Z", "2006-01-02T15:04:05Z07:00"]
		let dates = dateStrings.compactMap { dateString -> Date? in
			Formatter.iso8601WithFractionalSeconds.date(from: dateString)
		}
		XCTAssertEqual(dates.count, 2)
	}

	func testDaysSubtracting() throws {
		let today = Date()
		let startOfday = Calendar.current.startOfDay(for: today)
		let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: startOfday)
		ALog.info("\(startOfday)")
		ALog.info("\(String(describing: weekAgo))")
	}
}
