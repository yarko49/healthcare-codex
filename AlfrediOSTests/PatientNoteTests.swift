//
//  PatientNoteTests.swift
//  AlfrediOSTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import alfred_ios
import Foundation
import XCTest

class PatientNoteTests: XCTestCase {
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testCarePlanNoteA() throws {
		let careplanNoteDictionary =
			"""
			{
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
			}
			"""
		let decoder = AlfredJSONDecoder()
		if let data = careplanNoteDictionary.data(using: .utf8) {
			let note = try decoder.decode(Note.self, from: data)
			XCTAssertEqual(note.author, "test", "invalid author")
			XCTAssertEqual(note.content, "test content here", "invalid content")
			XCTAssertEqual(note.title, "test")
			XCTAssertEqual(note.remoteId, "XXXX-ID-test", "invalid remote Id")
			XCTAssertEqual(note.groupId, "test", "invalid group Id")
			XCTAssertEqual(note.timezone, TimeZone(secondsFromGMT: 0), "invalid timezone")
			XCTAssertNil(note.effectiveDate)
		} else {
			throw URLError(.cannotDecodeRawData)
		}
	}

	func testCarePlanNoteB() throws {
		let careplanNoteDictionary =
			"""
			{
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
			"""
		let decoder = AlfredJSONDecoder()
		if let data = careplanNoteDictionary.data(using: .utf8) {
			let note = try decoder.decode(Note.self, from: data)
			XCTAssertEqual(note.author, "testB", "invalid author")
			XCTAssertEqual(note.content, "test", "invalid content")
			XCTAssertEqual(note.title, "test")
			XCTAssertEqual(note.remoteId, "XXXX-ID-test2", "invalid remote Id")
			XCTAssertEqual(note.groupId, "test", "invalid group Id")
			XCTAssertEqual(note.timezone, TimeZone(secondsFromGMT: 0), "invalid timezone")
			XCTAssertNil(note.effectiveDate)
		} else {
			throw URLError(.cannotDecodeRawData)
		}
	}

	func testPerformanceExample() throws {
		// This is an example of a performance test case.
		measure {
			// Put the code you want to measure the time of here.
		}
	}
}
