//
//  SQLiteTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 10/20/21.
//

@testable import Allie
import CareModel
import CodexFoundation
import CoreData
import XCTest

class CoreDataTests: XCTestCase {
	@Injected(\.careManager) var careManger: CareManager
	var uploadedOutcomes: [CHOutcome] = []
	var downlaodedOutcomes: [CHOutcome] = []
	var symptomsUploaded: [CHOutcome] = []

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		let downloaded = AllieTests.loadTestData(fileName: "DownlaodedOutcomes.json")
		downlaodedOutcomes = try CHFJSONDecoder().decode([CHOutcome].self, from: downloaded!)

		let upaloded = AllieTests.loadTestData(fileName: "UploadOutcomes.json")
		uploadedOutcomes = try CHFJSONDecoder().decode([CHOutcome].self, from: upaloded!)

		let symptom = AllieTests.loadTestData(fileName: "SymptomOutcomeUploaded.json")
		symptomsUploaded = try CHFJSONDecoder().decode([CHOutcome].self, from: symptom!)
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		uploadedOutcomes.removeAll()
		downlaodedOutcomes.removeAll()
	}

	func testSave() throws {
		let first = downlaodedOutcomes.first
		XCTAssertNotNil(first)
		let result = try careManger.dbInsert(outcome: first!)
		XCTAssertNotNil(result)
		XCTAssertNotNil(result!.uuid)
		XCTAssertNotNil(result!.sampleId)
		XCTAssertNotNil(result!.createdDate)
		XCTAssertNotNil(result!.updatedDate)
		XCTAssertNotNil(result!.remoteId)
		XCTAssertNotNil(result!.taskId)
		XCTAssertNotNil(result!.value)
		XCTAssertNotEqual(result!.remoteId, "")

		XCTAssertEqual(result!.uuid, first!.uuid)
		XCTAssertEqual(result!.sampleId, first!.healthKit?.sampleUUID)
		XCTAssertEqual(result!.createdDate, first!.createdDate)
		XCTAssertEqual(result!.updatedDate, first!.updatedDate)
		XCTAssertEqual(result!.remoteId, first!.remoteId)
		XCTAssertEqual(result!.taskId, first!.taskId)
	}

	func testReadUUID() throws {
		let first = downlaodedOutcomes.first
		XCTAssertNotNil(first)
		let result = try careManger.dbInsert(outcome: first!)
		XCTAssertNotNil(result)
		XCTAssertNotNil(result!.uuid)
		XCTAssertNotNil(result!.sampleId)
		XCTAssertNotNil(result!.createdDate)
		XCTAssertNotNil(result!.updatedDate)
		XCTAssertNotNil(result!.remoteId)
		XCTAssertNotNil(result!.taskId)
		XCTAssertNotNil(result!.value)
		XCTAssertNotEqual(result!.remoteId, "")

		let uuid = first?.uuid
		XCTAssertNotNil(uuid)
		let mapped = try careManger.dbFindFirst(sampleId: uuid!)
		XCTAssertNotNil(mapped)

		XCTAssertEqual(mapped!.uuid, first!.uuid)
		XCTAssertEqual(mapped!.sampleId, first!.healthKit?.sampleUUID)
		XCTAssertEqual(mapped!.remoteId, first!.remoteId)
		XCTAssertEqual(mapped!.taskId, first!.taskId)
		XCTAssertEqual(mapped!.createdDate, first!.createdDate)
		XCTAssertEqual(mapped!.updatedDate, first!.updatedDate)

		let outcome = mapped?.outcome
		XCTAssertNotNil(outcome)

		XCTAssertEqual(outcome!.uuid, first!.uuid)
		XCTAssertEqual(outcome!.healthKit?.sampleUUID, first!.healthKit?.sampleUUID)
		XCTAssertEqual(outcome!.remoteId, first!.remoteId)
		XCTAssertEqual(outcome!.taskId, first!.taskId)
		XCTAssertEqual(outcome!.createdDate, first!.createdDate)
		XCTAssertEqual(outcome!.updatedDate, first!.updatedDate)

		XCTAssertEqual(mapped!.uuid, outcome!.uuid)
		XCTAssertEqual(mapped!.sampleId, outcome!.healthKit?.sampleUUID)
		XCTAssertEqual(mapped!.remoteId, outcome!.remoteId)
		XCTAssertEqual(mapped!.taskId, outcome!.taskId)
		XCTAssertEqual(mapped!.createdDate, outcome!.createdDate)
		XCTAssertEqual(mapped!.updatedDate, outcome!.updatedDate)
	}

	func testReadSampleUUID() throws {
		let first = downlaodedOutcomes.first
		XCTAssertNotNil(first)
		let result = try careManger.dbInsert(outcome: first!)
		XCTAssertNotNil(result)
		XCTAssertNotNil(result!.uuid)
		XCTAssertNotNil(result!.sampleId)
		XCTAssertNotNil(result!.createdDate)
		XCTAssertNotNil(result!.updatedDate)
		XCTAssertNotNil(result!.remoteId)
		XCTAssertNotNil(result!.taskId)
		XCTAssertNotNil(result!.value)
		XCTAssertNotEqual(result!.remoteId, "")

		let uuid = first?.healthKit?.sampleUUID
		XCTAssertNotNil(uuid)
		let outcome = try careManger.dbFindFirstOutcome(sampleId: uuid!)
		XCTAssertNotNil(outcome)

		XCTAssertEqual(outcome!.uuid, first!.uuid)
		XCTAssertEqual(outcome!.healthKit?.sampleUUID, first!.healthKit?.sampleUUID)
		XCTAssertEqual(outcome!.remoteId, first!.remoteId)
		XCTAssertEqual(outcome!.taskId, first!.taskId)
		XCTAssertEqual(outcome!.createdDate, first!.createdDate)
		XCTAssertEqual(outcome!.updatedDate, first!.updatedDate)
	}

	func testReadSymptomUploaded() throws {
		let first = symptomsUploaded.first
		XCTAssertNotNil(first)
		let result = try careManger.dbInsert(outcome: first!)
		XCTAssertNotNil(result)
		XCTAssertNotNil(result!.uuid)
		XCTAssertNil(result!.sampleId)
		XCTAssertNotNil(result!.createdDate)
		XCTAssertNotNil(result!.updatedDate)
		XCTAssertNotNil(result!.remoteId)
		XCTAssertNotNil(result!.taskId)
		XCTAssertNotNil(result!.value)
		XCTAssertNotEqual(result!.remoteId, "")

		let uuid = first?.uuid
		XCTAssertNotNil(uuid)
		let outcome = try careManger.dbFindFirstOutcome(uuid: uuid!)
		XCTAssertNotNil(outcome)

		XCTAssertEqual(outcome!.uuid, first!.uuid)
		XCTAssertEqual(outcome!.remoteId, first!.remoteId)
		XCTAssertEqual(outcome!.taskId, first!.taskId)
		XCTAssertEqual(outcome!.createdDate, first!.createdDate)
		XCTAssertEqual(outcome!.updatedDate, first!.updatedDate)
	}
}
