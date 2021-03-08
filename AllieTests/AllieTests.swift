//
//  AllieTests.swift
//  AllieiTests
//
//  Created by Waqar Malik on 11/23/20.
//

@testable import Allie
import CareKitStore
import Foundation
import XCTest

class AllieTests: XCTestCase {
	var client: APIClient?

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

	func testCarePlanValueSpaceResponse() throws {
		let carePlanResponse = AllieTests.loadTestData(fileName: "ValueSpaceResponse.json")
		XCTAssertNotNil(carePlanResponse)
		let url = APIRouter.getCarePlan(vectorClock: false, valueSpaceSample: false).urlRequest?.url
		XCTAssert(!carePlanResponse!.isEmpty)
		URLProtocolMock.testData[url!] = carePlanResponse
		URLProtocolMock.response = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
		let expect = expectation(description: "CarePlanResponse")
		client?.getCarePlan(completion: { result in
			switch result {
			case .failure(let error):
				XCTFail("Error Fetching Care Plan = \(error.localizedDescription)")
			case .success(let carePlanResponse):
				XCTAssertNotNil(carePlanResponse.carePlans)
				XCTAssertTrue(true)
				expect.fulfill()
			}
			URLProtocolMock.response = nil
		})
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testDefaultDiabetesCarePlan() throws {
		let carePlanResponse = AllieTests.loadTestData(fileName: "DefaultDiabetesCarePlan.json")
		XCTAssertNotNil(carePlanResponse)
		let url = APIRouter.getCarePlan(vectorClock: false, valueSpaceSample: false).urlRequest?.url
		XCTAssert(!carePlanResponse!.isEmpty)
		URLProtocolMock.testData[url!] = carePlanResponse
		URLProtocolMock.response = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
		let expect = expectation(description: "DefaultDiabetesCarePlan")
		client?.getCarePlan(completion: { result in
			switch result {
			case .failure(let error):
				XCTFail("Error Fetching DefaultDiabetes Care Plan = \(error.localizedDescription)")
			case .success(let carePlanResponse):
				XCTAssertNotNil(carePlanResponse.carePlans)
				XCTAssertTrue(true)
				expect.fulfill()
			}
			URLProtocolMock.response = nil
		})
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testDefaultCarePlan() throws {
		let carePlanResponseData = AllieTests.loadTestData(fileName: "DefaultCarePlan.json")
		XCTAssertNotNil(carePlanResponseData)
		let decoder = CHJSONDecoder()
		let carePlanResponse = try decoder.decode(CarePlanResponse.self, from: carePlanResponseData!)
		let allTasks = carePlanResponse.allTasks
		for task in allTasks {
			let ockTask = task.ockTask as? OCKTask
			print("effective \(task.effectiveDate), \(ockTask?.effectiveDate ?? Date())")
		}
	}

	func testInsertCarePlanStore() throws {
		let carePlanResponseData = AllieTests.loadTestData(fileName: "DefaultCarePlan.json")
		XCTAssertNotNil(carePlanResponseData)
		let decoder = CHJSONDecoder()
		let carePlanResponse = try decoder.decode(CarePlanResponse.self, from: carePlanResponseData!)
		let storeManager = CareManager()
		let expect = expectation(description: "InsertCarePlans")
		storeManager.insert(carePlansResponse: carePlanResponse, for: storeManager.patient) { result in
			switch result {
			case .failure(let error):
				XCTFail("Error Fetching DefaultDiabetes Care Plan = \(error.localizedDescription)")
			case .success(let cardList):
				print(cardList)
				XCTAssertTrue(true)
				expect.fulfill()
			}
		}
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testGetNotifications() {
		let response = AllieTests.loadTestData(fileName: "Notifications.json")
		XCTAssertNotNil(response)
		let url = APIRouter.getNotifications.urlRequest?.url
		XCTAssert(!response!.isEmpty)
		URLProtocolMock.testData[url!] = response
		URLProtocolMock.response = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
		let expect = expectation(description: "FIHRQuestionnaire")
		client?.getCardList(completion: { result in
			switch result {
			case .failure(let error):
				XCTFail("Error Fetching DefaultDiabetes Care Plan = \(error.localizedDescription)")
			case .success(let cardList):
				XCTAssertEqual(cardList.notifications.count, 6)
				XCTAssertTrue(true)
				expect.fulfill()
			}
			URLProtocolMock.response = nil
		})
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testImageDownload() throws {
		let imageURL = Bundle(for: AllieTests.self).url(forResource: "TestImage", withExtension: "png")
		XCTAssertNotNil(imageURL, "Missing Image File")
		let data = try Data(contentsOf: imageURL!)
		URLProtocolMock.testData[imageURL!] = data
		URLProtocolMock.response = HTTPURLResponse(url: imageURL!, statusCode: 200, httpVersion: nil, headerFields: [Request.Header.contentType: Request.ContentType.png])
		let expect = expectation(description: "ImageDownload")
		client?.loadImage(urlString: imageURL!.absoluteString, completion: { result in
			switch result {
			case .failure(let error):
				XCTFail("Error Fetching Image = \(error.localizedDescription)")
			case .success(let image):
				XCTAssertTrue(true)
				expect.fulfill()
			}
			URLProtocolMock.response = nil
		})
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}
}
