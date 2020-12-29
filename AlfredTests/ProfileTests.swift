//
//  ProfileTests.swift
//  AlfredTests
//
//  Created by Waqar Malik on 12/29/20.
//

@testable import Alfred
import XCTest

class ProfileTests: XCTestCase {
	var client: AlfredClient?

	override func setUpWithError() throws {
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [URLProtocolMock.self]
		let session = URLSession(configuration: config)
		client = AlfredClient(session: session)
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		client = nil
	}

	func testProfileEncode() throws {
		let response = AlfredTests.loadTestData(fileName: "Profile.json")
		XCTAssertNotNil(response)
		let url = APIRouter.getProfile.urlRequest?.url
		XCTAssert(!response!.isEmpty)
		URLProtocolMock.testData[url!] = response
		URLProtocolMock.response = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
		let expect = expectation(description: "GetProfile")
		client?.getProfile(completion: { result in
			switch result {
			case .failure(let error):
				XCTFail("Error Fetching Profile = \(error.localizedDescription)")
			case .success(let profile):
				XCTAssertEqual(profile.signUpCompleted, true)
				XCTAssertTrue(true)
				expect.fulfill()
			}
			URLProtocolMock.response = nil
		})
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testGetPofile() throws {
		let response = AlfredTests.loadTestData(fileName: "Profile2.json")
		XCTAssertNotNil(response)
		let url = APIRouter.getProfile.urlRequest?.url
		XCTAssert(!response!.isEmpty)
		URLProtocolMock.testData[url!] = response
		URLProtocolMock.response = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
		let expect = expectation(description: "GetProfile")
		client?.getProfile(completion: { result in
			switch result {
			case .failure(let error):
				XCTFail("Error Fetching Profile2 = \(error.localizedDescription)")
			case .success(let profile):
				XCTAssertEqual(profile.signUpCompleted, true)
				XCTAssertTrue(true)
				expect.fulfill()
			}
			URLProtocolMock.response = nil
		})
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testPostPofile() throws {
		let profileData = AlfredTests.loadTestData(fileName: "Profile.json")
		XCTAssertNotNil(profileData)
		let profile = try JSONDecoder().decode(Profile.self, from: profileData!)
		let url = APIRouter.postProfile(profile: profile).urlRequest?.url
		URLProtocolMock.testData[url!] = profileData!
		URLProtocolMock.response = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
		let expect = expectation(description: "PostProfile")
		client?.postProfile(profile: profile, completion: { result in
			switch result {
			case .failure(let error):
				XCTFail("Error Fetching Profile2 = \(error.localizedDescription)")
			case .success(let value):
				XCTAssertEqual(value, true)
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
