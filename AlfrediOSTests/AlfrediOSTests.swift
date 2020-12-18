//
//  AlfrediOSTests.swift
//  AlfrediOSTests
//
//  Created by Waqar Malik on 11/23/20.
//

@testable import alfred_ios
import AlfredCore
import Foundation
import XCTest

class AlfrediOSTests: XCTestCase {
	var webService: WebService?
	var carePlanResponse: Data!

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [URLProtocolMock.self]

		// and create the URLSession from that
		let session = URLSession(configuration: config)
		webService = WebService(baseURL: URL(string: AppConfig.apiBaseUrl)!, session: session)
		carePlanResponse = AlfrediOSTests.loadTestData(fileName: "ValueSpaceResponse.json")
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		webService?.cancelAll()
		webService = nil
		carePlanResponse = nil
	}

	func testCarePlanResponse() throws {
//		let url = APIRouter.getCarePlan(vectorClock: false, valueSpaceSample: true).urlRequest?.url
//		XCTAssert(!carePlanResponse.isEmpty)
//		URLProtocolMock.testData[url!] = carePlanResponse
//		URLProtocolMock.response = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
//		let expect = expectation(description: "CarePlanResponse")
//		webService?.getCarePlanResponse(completion: { result in
//			switch result {
//			case .failure(let error):
//				XCTFail("Error Fetching Company Profile = \(error.localizedDescription)")
//			case .success(let carePlanResponse):
//				XCTAssertTrue(true)
//				expect.fulfill()
//			}
//			URLProtocolMock.response = nil
//		})
//		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testPerformanceExample() throws {
		// This is an example of a performance test case.
		measure {
			// Put the code you want to measure the time of here.
		}
	}

	static func loadTestData(fileName: String) -> Data? {
		let components = fileName.components(separatedBy: ".")
		assert(components.count == 2)
		guard let url = Bundle(for: AlfrediOSTests.self).url(forResource: components[0], withExtension: components[1]) else {
			return nil
		}
		guard let data = try? Data(contentsOf: url) else {
			return nil
		}
		return data
	}
}
