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

	func testParseTokenURL() throws {
		let url = URL(string: "https://patient-ehr.codexhealth.com/?code=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJ1cm46b2lkOmZoaXIiLCJjbGllbnRfaWQiOiI1NjU0MjJkMi02N2I5LTRiNDItYmNmZi1kYWI3NDEyNzE0ODMiLCJlcGljLmVjaSI6InVybjplcGljOk9wZW4uRXBpYy1jdXJyZW50IiwiZXBpYy5tZXRhZGF0YSI6ImlZcUZ1OHgwUDNxbzNfaW1TZUhyMm1PTm8yd3pNb3pHU0Q2SUVOTzdGaDNNeFpvMXd6T1BDLVlDSXlwZkZoTkhYYkxBRjJmamg2anFZa29lWC1aR3Jvalo5YWx5di1aUnpRQU0wNUQ0dkFCZkZObVpEbUNzdlpSbExmZlJpSWwzIiwiZXBpYy50b2tlbnR5cGUiOiJjb2RlIiwiZXhwIjoxNjI4NjM1NjM4LCJpYXQiOjE2Mjg2MzUzMzgsImlzcyI6InVybjpvaWQ6ZmhpciIsImp0aSI6ImEwZTM4NGJjLTkzMTctNGM0Ny1iNTM1LTJiNjg5M2MwMzQxYyIsIm5iZiI6MTYyODYzNTMzOCwic3ViIjoiZWI0R2lhN0Z5aWp0UG1Ya3J0alJwUHczIn0.hJI_fkRtgiar_ons3XEN_DcR_KAnw5IJ6dARFRLxvYxvZhghuZoZumJ1WVGoUkRcWnp6rQBd-qrappLeH4axwovLpuWuXCnYyOuwExytTf6dN87R0RAgcNCG3YO_eFEJY3cqQaOLiGimgrQUiycsGiPKuE9kGTiIIM0lN1EIU1ZbT_FEqog-se-hrRtvVtQPkJ2FDAeqJS8_7LwJwVxX2DG9IYajIhmhthmB1Fan7DLIetTBuVkBZtubdJ9z4fhKYjXypsQ21ypH1ArEILFGIn0qtY56EmfUls1uUstMwFCSHG35Wt45Ne1hazzBDZxqOwE3x8KN8ZVex0Xw8iBcWg&state=2021-08-10T16%3a41%3a39-06%3a00")
		XCTAssertNotNil(url)
		let urlComponents = URLComponents(string: url!.absoluteString)
		XCTAssertNotNil(urlComponents)
		let queryItems = urlComponents?.queryItems
		let token = queryItems?.first(where: { item in
			item.name == "code"
		})?.value
		let state = queryItems?.first(where: { item in
			item.name == "state"
		})?.value

		XCTAssertNotNil(token)
		XCTAssertNotNil(state)
	}
}
