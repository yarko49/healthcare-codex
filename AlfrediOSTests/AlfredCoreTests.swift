//
//  AlfredCoreTests.swift
//  AlfredCoreTests
//
//  Created by Waqar Malik on 12/10/20.
//

@testable import alfred_ios
import XCTest

class AlfredCoreTests: XCTestCase {
	var webService: WebService?

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [URLProtocolMock.self]

		// and create the URLSession from that
		let session = URLSession(configuration: config)
		let url = URL(string: "https://dev.alfred.codexhealth.com/v0")
		webService = WebService(session: session)
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		webService = nil
	}

	func testImageDownload() throws {
		let imageURL = Bundle(for: AlfredCoreTests.self).url(forResource: "TestImage", withExtension: "png")
		XCTAssertNotNil(imageURL, "Missing Image File")
		let data = try Data(contentsOf: imageURL!)
		URLProtocolMock.testData[imageURL!] = data
		URLProtocolMock.response = HTTPURLResponse(url: imageURL!, statusCode: 200, httpVersion: nil, headerFields: [Request.Header.contentType: Request.ContentType.png])
		let expect = expectation(description: "ImageDownload")
		webService?.loadImage(urlString: imageURL!.absoluteString, completion: { result in
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

	func testPerformanceExample() throws {
		// This is an example of a performance test case.
		measure {
			// Put the code you want to measure the time of here.
		}
	}
}
