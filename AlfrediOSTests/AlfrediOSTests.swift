//
//  AlfrediOSTests.swift
//  AlfrediOSTests
//
//  Created by Waqar Malik on 11/23/20.
//

@testable import alfred_ios
import Foundation
import XCTest

class AlfrediOSTests: XCTestCase {
	var webService: CareWebService?

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [URLProtocolMock.self]

		// and create the URLSession from that
		let session = URLSession(configuration: config)
		webService = CareWebService(session: session)
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		webService?.cancelAll()
		webService = nil
	}

	func testCarePlans() throws {
		guard let data = AlfrediOSTests.loadTestData(fileName: "CarePlanResponse.json"), let url = APIRouter.getCarePlan(vectorClock: false, valueSpaceSample: false).urlRequest?.url else {
			XCTFail("Care Plans data file missing")
			return
		}
		XCTAssert(!data.isEmpty)
		URLProtocolMock.testData[url] = data
		URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
		let expect = expectation(description: "CarePlan")
		webService?.getCarePlan(completion: { [self] result in
			switch result {
			case .failure(let error):
				XCTFail("Error Fetching Company Profile = \(error.localizedDescription)")
			case .success(let carePlanResponse):
				self.testCarePlanResponse(response: carePlanResponse)
				expect.fulfill()
			}
			URLProtocolMock.response = nil
		})
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	fileprivate func saveTimeZone() {
		struct MyTimeZone: Codable {
			let timeZone: TimeZone
		}
		let mytimzZone = MyTimeZone(timeZone: .current)
		do {
			let data = try JSONEncoder().encode(mytimzZone)
			try data.write(to: URL(fileURLWithPath: "/tmp/TimeZone.json"))
		} catch {
			XCTFail("Care Plans data file missing")
		}
	}

	func testCarePlanResponse() throws {
		guard let data = AlfrediOSTests.loadTestData(fileName: "CarePlanResponse.json"), let url = APIRouter.getCarePlan(vectorClock: false, valueSpaceSample: false).urlRequest?.url else {
			XCTFail("Care Plans data file missing")
			return
		}
		XCTAssert(!data.isEmpty)
		URLProtocolMock.testData[url] = data
		URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
		let expect = expectation(description: "CarePlanResponse")
		webService?.getCarePlanResponse(completion: { result in
			switch result {
			case .failure(let error):
				XCTFail("Error Fetching Company Profile = \(error.localizedDescription)")
			case .success(let carePlanResponse):
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

	func testCarePlanResponse(response: [String: Any]) {
		let patients = response["patients"] as? [String: Any]
		XCTAssertNotNil(patients, "Missing Patients")
		testPatients(patients: patients!)
		let carePlans = response["carePlans"] as? [String: Any]
		XCTAssertNotNil(carePlans, "Missing Care Plans")
		testCarePlans(plans: carePlans!)
		let tasks = response["tasks"] as? [String: Any]
		XCTAssertNotNil(tasks, "Missing Tasks")
		testTasks(tasks: tasks!)
		let vectorClock = response["vectorClock"] as? [String: Any]
		XCTAssertNotNil(vectorClock, "Missing VectorClock")
		testVectorClock(clock: vectorClock!)
	}

	func testPatients(patients: [String: Any]) {
		let patient = patients["patientID"] as? [String: Any]
		XCTAssertNotNil(patient, "Missing Patient")
	}

	func testCarePlans(plans: [String: Any]) {
		let planA = plans["defaultCarePlanA"] as? [String: Any]
		XCTAssertNotNil(planA, "Missing Care PlanA")

		let planB = plans["defaultCarePlanB"] as? [String: Any]
		XCTAssertNotNil(planB, "Missing Care PlanB")
	}

	func testTasks(tasks: [String: Any]) {
		let task1 = tasks["defaultCarePlanA"] as? [String: Any]
		XCTAssertNotNil(task1, "Missing Task 1")

		let task2 = tasks["defaultCarePlanA"] as? [String: Any]
		XCTAssertNotNil(task2, "Missing Task 2")
	}

	func testVectorClock(clock: [String: Any]) {
		let clockValue = clock["backend"] as? Int64
		XCTAssertNotNil(clockValue, "Clock Value Missing")
		XCTAssertEqual(clockValue, 0, "Values do not match")
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
