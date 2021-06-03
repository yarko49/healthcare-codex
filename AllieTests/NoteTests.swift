//
//  PatientNoteTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 12/6/20.
//

@testable import Allie
import CareKitStore
import Foundation
import XCTest

class NoteTests: XCTestCase {
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
			  "author" : "test",
			  "content" : "test content here",
			  "title" : "test",
			}
			"""
		let decoder = CHJSONDecoder()
		if let data = careplanNoteDictionary.data(using: .utf8) {
			let note = try decoder.decode(OCKNote.self, from: data)
			XCTAssertEqual(note.author, "test", "invalid author")
			XCTAssertEqual(note.content, "test content here", "invalid content")
			XCTAssertEqual(note.title, "test")
		} else {
			throw URLError(.cannotDecodeRawData)
		}
	}

	func testCarePlanNoteB() throws {
		let careplanNoteDictionary =
			"""
			{
			  "author" : "testB",
			  "content" : "test",
			  "title" : "test",
			}
			"""
		let decoder = CHJSONDecoder()
		if let data = careplanNoteDictionary.data(using: .utf8) {
			let note = try decoder.decode(OCKNote.self, from: data)
			XCTAssertEqual(note.author, "testB", "invalid author")
			XCTAssertEqual(note.content, "test", "invalid content")
			XCTAssertEqual(note.title, "test")
		} else {
			throw URLError(.cannotDecodeRawData)
		}
	}
}
