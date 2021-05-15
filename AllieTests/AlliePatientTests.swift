//
//  AlliePatientTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 3/28/21.
//

@testable import Allie
import CareKitStore
import XCTest

class AlliePatientTests: XCTestCase {
	var patient: AlliePatient!

	override func setUpWithError() throws {
		var name = PersonNameComponents()
		name.familyName = "Malik"
		name.givenName = "Waqar"
		name.middleName = "A"
		let id = "v4GJLsOR7HbVWD0SmZyLhrDs3vq1"
		let uuid = "3522daf3-422b-487f-bc79-d52d7aadb9eb"
		patient = AlliePatient(id: id, name: name)
		patient.birthday = Date(timeIntervalSince1970: 0)
		patient.sex = .male
		patient.allergies = ["pollen"]
		patient.groupIdentifier = "existing"
		patient.notes = []
		patient.tags = ["tag1", "tag2", "tag3"]
		patient.timezone = TimeZone.current
		patient.createdDate = Calendar.current.startOfDay(for: Date())
		patient.updatedDate = Calendar.current.startOfDay(for: Date())
		patient.userInfo = [:]
		patient.remoteId = uuid
		patient.effectiveDate = Calendar.current.startOfDay(for: Date())
		patient.profile.email = "wmalloc+codex@gmail.com"
		patient.profile.phoneNumber = "14158945812"
		patient.profile.deviceManufacturer = "Apple"
		patient.profile.deviceSoftwareVersion = "14.4.2"
		patient.profile.fhirId = uuid
		patient.profile.heightInInches = 70
		patient.profile.weightInPounds = 212
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testEncodeDecode() throws {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		let encoded = try encoder.encode(patient)
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		let decoded = try decoder.decode(AlliePatient.self, from: encoded)
		try comparePatients(lhs: patient, rhs: decoded)
	}

	func testEncodeToKeychain() throws {
		Keychain.save(patient: patient)
		let fromKeychain = Keychain.readPatient(forKey: patient.id)
		try comparePatients(lhs: patient, rhs: fromKeychain)
	}

	func comparePatients(lhs: AlliePatient!, rhs: AlliePatient!) throws {
		XCTAssertNotNil(lhs)
		XCTAssertNotNil(lhs.remoteID)
		XCTAssertNotNil(lhs.profile)
		XCTAssertNotNil(lhs.profile.email)
		XCTAssertNotNil(lhs.profile.phoneNumber)
		XCTAssertNotNil(lhs.profile.deviceManufacturer)
		XCTAssertNotNil(lhs.profile.deviceSoftwareVersion)
		XCTAssertNotNil(lhs.profile.fhirId)
		XCTAssertNotNil(lhs.profile.heightInInches)
		XCTAssertNotNil(lhs.profile.weightInPounds)

		XCTAssertNotNil(rhs)
		XCTAssertNotNil(rhs.remoteID)
		XCTAssertNotNil(rhs.profile)
		XCTAssertNotNil(rhs.profile.email)
		XCTAssertNotNil(rhs.profile.phoneNumber)
		XCTAssertNotNil(rhs.profile.deviceManufacturer)
		XCTAssertNotNil(rhs.profile.deviceSoftwareVersion)
		XCTAssertNotNil(rhs.profile.fhirId)
		XCTAssertNotNil(rhs.profile.heightInInches)
		XCTAssertNotNil(rhs.profile.weightInPounds)

		XCTAssertEqual(rhs, rhs)
		XCTAssertEqual(rhs.profile, lhs.profile)
	}
}
