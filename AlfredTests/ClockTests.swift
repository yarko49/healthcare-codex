//
//  ClockTests.swift
//  AlfrediOSTests
//
//  Created by Waqar Malik on 11/24/20.
//

@testable import Alfred
import CareKitStore
import Foundation
import XCTest

class ClockTests: XCTestCase {
	var clock: VectorClock?

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		clock = VectorClock(uuid: UUID())
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testClockProperties() throws {
		XCTAssertNotNil(clock, "Clock is nil")
		XCTAssertNotNil(clock?.vector, "Vector String is nil")
		let expect = expectation(description: "ClockConversion")
		do {
			try clock?.decode(completion: { [self] vector in
				XCTAssertNotNil(vector, "Error decoding vector")
				do {
					let vectorString = try self.clock?.encode(clock: vector!)
					XCTAssertEqual(clock?.vector, vectorString, "conversion is invalid")
				} catch {
					XCTFail(error.localizedDescription)
				}
				expect.fulfill()
			})
		} catch {
			XCTFail(error.localizedDescription)
		}
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testPerformanceExample() throws {
		// This is an example of a performance test case.
		measure {
			// Put the code you want to measure the time of here.
		}
	}
}
