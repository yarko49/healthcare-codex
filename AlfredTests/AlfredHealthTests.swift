//
//  AlfredHealthTests.swift
//  AlfredHealthTests
//
//  Created by Waqar Malik on 12/10/20.
//

@testable import alfred_ios
import XCTest

class AlfredHealthTests: XCTestCase {
	static var wholeDate: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		return formatter
	}

	static var wholeDateNoTimeZoneRequest: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
		return formatter
	}

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testExample() throws {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
	}

	func testPerformanceExample() throws {
		// This is an example of a performance test case.
		measure {
			// Put the code you want to measure the time of here.
		}
	}

	static func loadTestData(fileName: String) -> Data? {
		let components = fileName.components(separatedBy: ".")
		assert(components.count == 2)
		guard let url = Bundle(for: AlfredHealthTests.self).url(forResource: components[0], withExtension: components[1]) else {
			return nil
		}
		guard let data = try? Data(contentsOf: url) else {
			return nil
		}
		return data
	}
}
