//
//  ConersationsTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 6/28/21.
//

@testable import Allie
import XCTest

class ConersationsTests: XCTestCase {
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testConversations() throws {
		let data = """
		{
		  "tokens": [
		    {
		      "accessToken": "eyJhbGciOiJIUzI1NiIsImN0eSI6InR3aWxpby1mcGE7dj0xIiwidHlwIjoiSldUIn0.eyJleHAiOjE2MjQ5NTE1NTgsImdyYW50cyI6eyJjaGF0Ijp7InNlcnZpY2Vfc2lkIjoiSVM3ZmE5OWU0ZGUwYmI0MDM3OWFjYzIyNmY0YzcwMzU3NCJ9LCJpZGVudGl0eSI6IkVUaGlHaU13dVdnaGhYdjZMdmVwZDZZRkxaNDIifSwiaWF0IjoxNjI0OTQ3OTU4LCJpc3MiOiJTSzVkZjcyMjYyZTdiMDI3ZGZiNTUwYmRjOGYzM2M3NGEwIiwianRpIjoiU0s1ZGY3MjI2MmU3YjAyN2RmYjU1MGJkYzhmMzNjNzRhMC0xNjI0OTQ3OTU4Iiwic3ViIjoiQUMzMjEyN2RmM2Q2NDI0MWQ0OThmZDkyMWJjZGJhOGFhYSJ9.Bd0XV4VduLMcwKrQVyCih7fJqp_Tx-jBrYxWaXGZ_BA",
		      "healthcareProviderOrganizationId": "",
		      "serviceSid": "IS7fa99e4de0bb40379acc226f4c703574",
		      "expires": "2020-11-11T01:31:00.343Z"
		    }
		  ]
		}
		""".data(using: .utf8)
		XCTAssertNotNil(data)
		let decoder = CHJSONDecoder()
		let conversations = try decoder.decode(CHConversationsTokens.self, from: data!)
		ALog.info("date = \(conversations.tokens.first?.expirationDate)")
	}

	func testConversationsUsersTests() throws {
		let body = """
		{
		    "users": ["EThiGiMwuWghhXv6Lvepd6YFLZ42"]
		}
		""".data(using: .utf8)
		let data = AllieTests.loadTestData(fileName: "ConversationsUsers.json")
		XCTAssertNotNil(data)
		let decoded = try CHJSONDecoder().decode(CHConversationsUsers.self, from: data!)
		XCTAssertEqual(decoded.users.count, 1)
	}
}
