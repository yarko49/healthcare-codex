//
//  PatientTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import Allie
import Foundation
import XCTest

class PatientTests: XCTestCase {
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testPatientOtherA() throws {
		let patientDictionary =
			"""
			{
			      "id" : "patientOtherA",
			      "remoteID" : "XXX-ID-patientOtherA",
			      "createdDate" : "2020-11-25T02:10:11.022Z",
			      "asset" : "",
			      "tags" : [
			        "tag1",
			        "tag2"
			      ],
			      "source" : "",
			      "updatedDate" : "2020-11-25T02:10:11.022Z",
			      "birthday" : "2020-11-25T00:00:00Z",
			      "groupIdentifier" : "shared",
			      "timezone" : 28800,
			      "effectiveDate" : "2020-11-25T02:10:11.022Z",
			      "userInfo" : {
			        "key1" : "value1",
			        "key2" : "value2"
			      },
			      "name" : {
			        "namePrefix" : "",
			        "givenName" : "other-first",
			        "nameSuffix" : "",
			        "middleName" : "other-middle",
			        "familyName" : "other-last",
			        "nickname" : "jon"
			      }
			    }
			"""
		let patient = try patientDecode(string: patientDictionary)
		XCTAssertEqual(patient.id, "patientOtherA", "invalid Id")
		XCTAssertEqual(patient.groupIdentifier, "shared", "invalid groud Id")
		XCTAssertEqual(patient.timezone, TimeZone(identifier: "America/Los_Angeles"), "invalid timezone")
		XCTAssertNotNil(patient.createdDate)
		XCTAssertNotNil(patient.updatedDate)
		XCTAssertNotNil(patient.effectiveDate)
		XCTAssertNotNil(patient.birthday)
		XCTAssertNotNil(patient.name)
		XCTAssertNotNil(patient.tags)
		XCTAssertNotNil(patient.userInfo)
	}

	func testPatientOtherC() throws {
		let patientDictionary =
			"""
			    {
			      "id" : "patientOtherC",
			      "remoteID" : "XXX-ID-patientOtherC",
			      "createdDate" : "2020-11-25T02:10:11.022Z",
			      "asset" : "",
			      "updatedDate" : "2020-11-25T02:10:11.022Z",
			      "source" : "",
			      "birthday" : "1900-11-25T00:00:00Z",
			      "groupIdentifier" : "inactive",
			      "deletedDate" : "2020-11-27T02:10:11.022Z",
			      "timezone" : 0,
			      "effectiveDate" : "2020-11-25T02:10:11.022Z",
			      "name" : {
			        "namePrefix" : "other",
			        "givenName" : "first",
			        "nameSuffix" : "",
			        "middleName" : "",
			        "familyName" : "last",
			        "nickname" : ""
			      }
			    }
			"""
		let patient = try patientDecode(string: patientDictionary)
		XCTAssertEqual(patient.id, "patientOtherC", "invalid Id")
		XCTAssertEqual(patient.groupIdentifier, "inactive", "invalid groud Id")
		XCTAssertEqual(patient.timezone, TimeZone(identifier: "America/Los_Angeles"), "invalid timezone")
		XCTAssertNotNil(patient.createdDate)
		XCTAssertNotNil(patient.updatedDate)
		XCTAssertNotNil(patient.effectiveDate)
		XCTAssertNotNil(patient.birthday)
		XCTAssertNotNil(patient.name)
		XCTAssertNil(patient.tags)
		XCTAssertNil(patient.userInfo)
	}

	func testPatientId() throws {
		let patientDictionary =
			"""
			    {
			          "id" : "patientId",
			          "remoteID" : "XXX-ID-patientId",
			          "createdDate" : "2020-11-25T02:10:11.022Z",
			          "asset" : "",
			          "tags" : [
			            "tag1",
			            "tag2"
			          ],
			          "source" : "",
			          "updatedDate" : "2020-11-25T02:10:11.022Z",
			          "birthday" : "2020-11-25T00:00:00Z",
			          "groupIdentifier" : "active",
			          "timezone" : 28800,
			          "effectiveDate" : "2020-11-25T02:10:11.022Z",
			          "userInfo" : {
			            "key1" : "value1",
			            "key2" : "value2"
			          },
			          "name" : {
			            "namePrefix" : "",
			            "givenName" : "first",
			            "nameSuffix" : "jr",
			            "middleName" : "middle",
			            "familyName" : "last",
			            "nickname" : ""
			          }
			        }
			"""
		let patient = try patientDecode(string: patientDictionary)
		XCTAssertEqual(patient.id, "patientId", "invalid Id")
		XCTAssertEqual(patient.groupIdentifier, "active", "invalid groud Id")
		XCTAssertEqual(patient.timezone, TimeZone(identifier: "America/Los_Angeles"), "invalid timezone")
		XCTAssertNotNil(patient.createdDate)
		XCTAssertNotNil(patient.updatedDate)
		XCTAssertNotNil(patient.effectiveDate)
		XCTAssertNotNil(patient.birthday)
		XCTAssertNotNil(patient.name)
		XCTAssertNotNil(patient.tags)
		XCTAssertNotNil(patient.userInfo)
	}

	func patientDecode(string: String) throws -> CHPatient {
		let decoder = CHJSONDecoder()
		if let data = string.data(using: .utf8) {
			let patient = try decoder.decode(CHPatient.self, from: data)
			return patient
		} else {
			throw URLError(.cannotDecodeRawData)
		}
	}
}
