//
//  OraganizationsTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 6/17/21.
//

@testable import Allie
import XCTest

class OraganizationsTests: XCTestCase {
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testOrganizations() throws {
		let data = AllieTests.loadTestData(fileName: "Organizations.json")
		XCTAssertNotNil(data)
		let decoder = CHJSONDecoder()
		let organizations = try decoder.decode(CHOrganizations.self, from: data!)
		XCTAssertEqual(organizations.registered.count, 1)
	}
}
