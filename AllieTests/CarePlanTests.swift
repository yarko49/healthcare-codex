//
//  CarePlanTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import Allie
import Foundation
import XCTest

class CarePlanTests: XCTestCase {
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testCarePlanA() throws {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		let careplanDictionary =
			"""
			{
			      "id" : "CarePlanA",
			      "remoteId" : "XXXX-ID-CarePlanA",
			      "asset" : "",
			      "tags" : [
			        "tag1",
			        "tag2"
			      ],
			      "source" : "",
			      "title" : "Personal",
			      "notes" : {
			        "carePlanNoteA" : {
			          "source" : "",
			          "author" : "test",
			          "content" : "test content here",
			          "remoteId" : "XXXX-ID-test",
			          "id" : "",
			          "title" : "test",
			          "groupIdentifier" : "test",
			          "timezone" : 0,
			          "asset" : "",
			          "effectiveDate" : null
			        },
			        "carePlanNoteB" : {
			          "source" : "",
			          "author" : "testB",
			          "content" : "test",
			          "remoteId" : "XXXX-ID-test2",
			          "id" : "",
			          "title" : "test",
			          "groupIdentifier" : "test",
			          "timezone" : 0,
			          "asset" : "",
			          "effectiveDate" : null
			        }
			      },
			      "groupIdentifier" : "PersonalCarePlan",
			      "timezone" : 28800,
			      "effectiveDate" : "2020-11-11T01:31:00.343Z",
			      "userInfo" : {
			        "key1" : "value1",
			        "key2" : "value2"
			      },
			      "patientId" : "patientId"
			    }
			"""
		let carePlan = try carePlanDecode(string: careplanDictionary)
		XCTAssertEqual(carePlan.id, "CarePlanA", "invalid Id")
		XCTAssertEqual(carePlan.patientId, "patientId", "invalid remote Id")
		XCTAssertEqual(carePlan.title, "Personal")
		XCTAssertEqual(carePlan.remoteId, "XXXX-ID-CarePlanA", "invalid remote Id")
		XCTAssertEqual(carePlan.groupIdentifier, "PersonalCarePlan", "invalid group Id")
		XCTAssertEqual(carePlan.timezone, TimeZone(secondsFromGMT: 28800), "invalid timezone")
		XCTAssertNotNil(carePlan.effectiveDate)
		XCTAssertNotNil(carePlan.tags)
		XCTAssertNotNil(carePlan.notes)
		XCTAssertNotNil(carePlan.userInfo)
	}

	func testCarePlanB() throws {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		let careplanDictionary =
			"""
			{
			      "source" : "",
			      "effectiveDate" : "2020-11-11T01:31:00.343Z",
			      "patientId" : "patientOtherA",
			      "remoteId" : "XXXX-ID-CarePlanB",
			      "id" : "CarePlanB",
			      "title" : "Codex Default Care Plan",
			      "groupIdentifier" : "HealthcareProviderXYZ",
			      "timezone" : 0,
			      "asset" : "",
			      "userInfo" : {
			        "key1" : "value1",
			        "key2" : "value2"
			      }
			    }
			"""
		let carePlan = try carePlanDecode(string: careplanDictionary)
		XCTAssertEqual(carePlan.id, "CarePlanB", "invalid Id")
		XCTAssertEqual(carePlan.patientId, "patientOtherA", "invalid remote Id")
		XCTAssertEqual(carePlan.title, "Codex Default Care Plan")
		XCTAssertEqual(carePlan.remoteId, "XXXX-ID-CarePlanB", "invalid remote Id")
		XCTAssertEqual(carePlan.groupIdentifier, "HealthcareProviderXYZ", "invalid group Id")
		XCTAssertEqual(carePlan.timezone, TimeZone(secondsFromGMT: 0), "invalid timezone")
		XCTAssertNotNil(carePlan.effectiveDate)
		XCTAssertNil(carePlan.tags)
		XCTAssertNil(carePlan.notes)
		XCTAssertNotNil(carePlan.userInfo)
	}

	func testCarePlanC() throws {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		let careplanDictionary =
			"""
			{
			      "source" : "",
			      "patientId" : "patientOtherC",
			      "deletedDate" : "2020-11-12T01:31:00.343Z",
			      "remoteId" : "XXXX-ID-CarePlanC",
			      "id" : "CarePlanC",
			      "title" : "Codex Deleted Care Plan",
			      "groupIdentifier" : "HealthcareProviderXYZ",
			      "timezone" : 0,
			      "asset" : "",
			      "effectiveDate" : "2020-11-11T01:31:00.343Z"
			    }
			"""
		let carePlan = try carePlanDecode(string: careplanDictionary)
		XCTAssertEqual(carePlan.id, "CarePlanC", "invalid Id")
		XCTAssertEqual(carePlan.patientId, "patientOtherC", "invalid remote Id")
		XCTAssertEqual(carePlan.title, "Codex Deleted Care Plan")
		XCTAssertEqual(carePlan.remoteId, "XXXX-ID-CarePlanC", "invalid remote Id")
		XCTAssertEqual(carePlan.groupIdentifier, "HealthcareProviderXYZ", "invalid group Id")
		XCTAssertEqual(carePlan.timezone, TimeZone(secondsFromGMT: 0), "invalid timezone")
		XCTAssertNotNil(carePlan.effectiveDate)
		XCTAssertNil(carePlan.tags)
		XCTAssertNil(carePlan.notes)
		XCTAssertNil(carePlan.userInfo)
	}

	func testCarePlanD() throws {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		let careplanDictionary =
			"""
			{
			      "source" : "test-clinician-healthcare",
			      "patientId" : "patientId",
			      "remoteId" : "XXXX-ID-CarePlanD",
			      "id" : "CarePlanD",
			      "title" : "Sourced Care Plan",
			      "groupIdentifier" : "HealthcareProviderXYZ",
			      "timezone" : 0,
			      "asset" : "alfred.codexhealth.com",
			      "effectiveDate" : "2020-11-11T01:31:00.343Z"
			    }
			"""
		let carePlan = try carePlanDecode(string: careplanDictionary)
		XCTAssertEqual(carePlan.id, "CarePlanD", "invalid Id")
		XCTAssertEqual(carePlan.patientId, "patientId", "invalid remote Id")
		XCTAssertEqual(carePlan.title, "Sourced Care Plan")
		XCTAssertEqual(carePlan.remoteId, "XXXX-ID-CarePlanD", "invalid remote Id")
		XCTAssertEqual(carePlan.groupIdentifier, "HealthcareProviderXYZ", "invalid group Id")
		XCTAssertEqual(carePlan.timezone, TimeZone(secondsFromGMT: 0), "invalid timezone")
		XCTAssertEqual(carePlan.source, "test-clinician-healthcare")
		XCTAssertEqual(carePlan.asset, "alfred.codexhealth.com")
		XCTAssertNotNil(carePlan.effectiveDate)
		XCTAssertNil(carePlan.tags)
		XCTAssertNil(carePlan.notes)
		XCTAssertNil(carePlan.userInfo)
	}

	func testCarePlanReverse() throws {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		let careplanDictionary =
			"""
			{
			      "id" : "CarePlanA",
			      "remoteId" : "XXXX-ID-CarePlanA",
			      "asset" : "",
			      "tags" : [
			        "tag1",
			        "tag2"
			      ],
			      "source" : "",
			      "title" : "Personal",
			      "notes" : {
			        "carePlanNoteA" : {
			          "source" : "",
			          "author" : "test",
			          "content" : "test content here",
			          "remoteId" : "XXXX-ID-test",
			          "id" : "",
			          "title" : "test",
			          "groupIdentifier" : "test",
			          "timezone" : 0,
			          "asset" : "",
			          "effectiveDate" : null
			        },
			        "carePlanNoteB" : {
			          "source" : "",
			          "author" : "testB",
			          "content" : "test",
			          "remoteId" : "XXXX-ID-test2",
			          "id" : "",
			          "title" : "test",
			          "groupIdentifier" : "test",
			          "timezone" : 0,
			          "asset" : "",
			          "effectiveDate" : null
			        }
			      },
			      "groupIdentifier" : "PersonalCarePlan",
			      "timezone" : 28800,
			      "effectiveDate" : "2020-11-11T01:31:00.343Z",
			      "userInfo" : {
			        "key1" : "value1",
			        "key2" : "value2"
			      },
			      "patientId" : "patientId"
			    }
			"""
		let carePlan = try carePlanDecode(string: careplanDictionary)
		let encoder = JSONEncoder()
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		encoder.dateEncodingStrategy = .formatted(formatter)
		let data = try encoder.encode(carePlan)
		let decoder = CHJSONDecoder()
		let reverse = try decoder.decode(CarePlan.self, from: data)
		// XCTAssertEqual(reverse, carePlan)
	}

	func testCarePlanEncodeDecode() throws {
		let data = AllieTests.loadTestData(fileName: "DefaultDiabetesCarePlan.json")
		XCTAssertNotNil(data)
		let decoder = CHJSONDecoder()
		let carePlanResponse = try decoder.decode(CarePlanResponse.self, from: data!)
		XCTAssertNotNil(carePlanResponse.tasks)
	}

	func carePlanDecode(string: String) throws -> CarePlan {
		let decoder = CHJSONDecoder()
		if let data = string.data(using: .utf8) {
			let carePlan = try decoder.decode(CarePlan.self, from: data)
			return carePlan
		} else {
			throw URLError(.cannotDecodeRawData)
		}
	}
}
