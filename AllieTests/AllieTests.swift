//
//  AllieTests.swift
//  AllieiTests
//
//  Created by Waqar Malik on 11/23/20.
//

@testable import Allie
import CareKitStore
import Combine
import Foundation
import WebService
import XCTest

class AllieTests: XCTestCase {
	var client: APIClient?
	var cancellables: Set<AnyCancellable> = []
	static func loadTestData(fileName: String) -> Data? {
		let components = fileName.components(separatedBy: ".")
		assert(components.count == 2)
		guard let url = Bundle(for: AllieTests.self).url(forResource: components[0], withExtension: components[1]) else {
			return nil
		}
		guard let data = try? Data(contentsOf: url) else {
			return nil
		}
		return data
	}

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [URLProtocolMock.self]
		let session = URLSession(configuration: config)
		client = APIClient(session: session)
		// and create the URLSession from that
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testDecodeCarePlan() throws {
		let carePlanResponseData = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(carePlanResponseData)
		let decoder = CHJSONDecoder()
		do {
			let carePlanResponse = try decoder.decode(CHCarePlanResponse.self, from: carePlanResponseData!)
			XCTAssertNotEqual(carePlanResponse.carePlans.count, 0)
		} catch {
			ALog.error("\(error)")
		}
	}

	func testCarePlanValueSpaceResponse() throws {
		let carePlanResponse = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(carePlanResponse)
		let url = try APIRouter.getCarePlan(option: .carePlan).url()
		XCTAssert(!carePlanResponse!.isEmpty)
		URLProtocolMock.testData[url] = carePlanResponse
		URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
		let expect = expectation(description: "CarePlanResponse")
		client?.getCarePlan()
			.sink(receiveCompletion: { result in
				if case .failure(let error) = result {
					XCTFail("Error Fetching Care Plan = \(error.localizedDescription)")
					URLProtocolMock.response = nil
				}
			}, receiveValue: { carePlanResponse in
				XCTAssertNotNil(carePlanResponse.carePlans)
				XCTAssertTrue(true)
				expect.fulfill()
				URLProtocolMock.response = nil
			}).store(in: &cancellables)
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testDefaultDiabetesCarePlan() throws {
		let carePlanResponse = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(carePlanResponse)
		let url = try APIRouter.getCarePlan(option: .carePlan).url()
		XCTAssert(!carePlanResponse!.isEmpty)
		URLProtocolMock.testData[url] = carePlanResponse
		URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
		let expect = expectation(description: "DefaultDiabetesCarePlan")
		client?.getCarePlan()
			.sink(receiveCompletion: { result in
				if case .failure(let error) = result {
					XCTFail("Error Fetching DefaultDiabetes Care Plan = \(error.localizedDescription)")
					URLProtocolMock.response = nil
				}
			}, receiveValue: { carePlanResponse in
				XCTAssertNotNil(carePlanResponse.carePlans)
				XCTAssertTrue(true)
				expect.fulfill()
				URLProtocolMock.response = nil
			}).store(in: &cancellables)
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testDefaultCarePlan() throws {
		let carePlanResponseData = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(carePlanResponseData)
		let decoder = CHJSONDecoder()
		do {
			let carePlanResponse = try decoder.decode(CHCarePlanResponse.self, from: carePlanResponseData!)
			let allTasks = carePlanResponse.tasks
			for task in allTasks {
				let ockTask = task.ockTask as? OCKTask
				print("effective \(task.effectiveDate), \(ockTask?.effectiveDate ?? Date())")
			}
		} catch {
			print("\(error)")
		}
	}

	func testInsertCarePlanStore() throws {
		let carePlanResponseData = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(carePlanResponseData)
		let decoder = CHJSONDecoder()
		let carePlanResponse = try decoder.decode(CHCarePlanResponse.self, from: carePlanResponseData!)
		let storeManager = CareManager.shared
		let expect = expectation(description: "InsertCarePlans")
		storeManager.process(carePlanResponse: carePlanResponse, forceReset: false) { result in
			switch result {
			case .failure(let error):
				XCTFail("Error Fetching DefaultDiabetes Care Plan \(error.localizedDescription)")
			case .success:
				expect.fulfill()
			}
		}
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testImageDownload() throws {
		let imageURL = Bundle(for: AllieTests.self).url(forResource: "TestImage", withExtension: "png")
		XCTAssertNotNil(imageURL, "Missing Image File")
		let data = try Data(contentsOf: imageURL!)
		URLProtocolMock.testData[imageURL!] = data
		URLProtocolMock.response = HTTPURLResponse(url: imageURL!, statusCode: 200, httpVersion: nil, headerFields: [Request.Header.contentType: Request.ContentType.png])
		let expect = expectation(description: "ImageDownload")
		client?.loadImage(url: imageURL!)
			.sink(receiveCompletion: { result in
				if case .failure(let error) = result {
					XCTFail("Error Fetching Image = \(error.localizedDescription)")
				}
			}, receiveValue: { _ in
				XCTAssertTrue(true)
				expect.fulfill()
			}).store(in: &cancellables)
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}
}
