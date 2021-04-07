//
//  CareKitStoreTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 3/16/21.
//

@testable import Allie
import CareKitStore
import ModelsR4
import XCTest

class CareKitStoreTests: XCTestCase {
	let careManager = CareManager()
	var client: APIClient?

	override func setUpWithError() throws {
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [URLProtocolMock.self]
		let session = URLSession(configuration: config)
		client = APIClient(session: session)
		try careManager.resetAllContents()
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testLoadPatient() throws {
		// try? careManager.resetAllContents()
		let expect = expectation(description: "Load Patient")
		careManager.loadPatient { result in
			switch result {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")

			case .success(let patient):
				ALog.info("\(patient.id)")
				expect.fulfill()
			}
		}
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testLoadAllPatient() throws {
		let expect = expectation(description: "Load Patient")
		careManager.store.fetchPatients { result in
			switch result {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
			case .success(let patients):
				patients.forEach { patient in
					ALog.info("\(patient.id), \(patient.createdDate), \(patient.updatedDate), \(patient.deletedDate), \(patient.effectiveDate)")
				}
				expect.fulfill()
			}
		}
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testGetPatientFromServer() throws {
		let carePlanResponse = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(carePlanResponse)
		let url = APIRouter.getCarePlan(vectorClock: false, valueSpaceSample: false).urlRequest?.url
		XCTAssert(!carePlanResponse!.isEmpty)
		URLProtocolMock.testData[url!] = carePlanResponse
		URLProtocolMock.response = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
		let expect = expectation(description: "DefaultCarePlan")
		client?.getCarePlan(completion: { result in
			switch result {
			case .failure(let error):
				XCTFail("Error Fetching DefaultDiabetes Care Plan = \(error.localizedDescription)")
			case .success(let carePlanResponse):
				let patients = carePlanResponse.patients
				XCTAssertNotNil(patients)
				XCTAssertEqual(patients?.count, 1)
				let patient = patients?.first
				XCTAssertNotNil(patient)
				XCTAssertNotNil(patient?.profile.fhirId)
				expect.fulfill()
			}
			URLProtocolMock.response = nil
		})
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testInsertCarePlanFromServer() throws {
		let carePlanResponseData = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(carePlanResponseData)
		let url = APIRouter.getCarePlan(vectorClock: false, valueSpaceSample: false).urlRequest?.url
		XCTAssert(!carePlanResponseData!.isEmpty)
		URLProtocolMock.testData[url!] = carePlanResponseData
		URLProtocolMock.response = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
		let expect = expectation(description: "DefaultCarePlan")
		let insert1 = expectation(description: "Insert CarePlan Store1")
		client?.getCarePlan(completion: { [weak self] result in
			switch result {
			case .failure(let error):
				XCTFail("Error Fetching DefaultDiabetes Care Plan = \(error.localizedDescription)")
			case .success(let response):
				self?.careManager.insert(carePlansResponse: response) { insertResult in
					switch insertResult {
					case .failure(let error):
						XCTFail("Error inserting DefaultDiabetes Care Plan = \(error.localizedDescription)")
					case .success:
						XCTAssertNotNil(self?.careManager.patient)
						insert1.fulfill()
					}
				}
				expect.fulfill()
			}
			URLProtocolMock.response = nil
		})
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect, insert1], timeout: 10))
	}

	func testInsertPatients() throws {
		let carePlanResponseData = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(carePlanResponseData)
		let url = APIRouter.getCarePlan(vectorClock: false, valueSpaceSample: false).urlRequest?.url
		XCTAssert(!carePlanResponseData!.isEmpty)
		URLProtocolMock.testData[url!] = carePlanResponseData
		URLProtocolMock.response = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
		let expect = expectation(description: "DefaultCarePlan")
		var carePlanRespons: CarePlanResponse?
		client?.getCarePlan(completion: { result in
			switch result {
			case .failure(let error):
				XCTFail("Error Fetching DefaultDiabetes Care Plan = \(error.localizedDescription)")
			case .success(let response):
				carePlanRespons = response
				expect.fulfill()
			}
			URLProtocolMock.response = nil
		})
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))

		if let carePlan = carePlanRespons {
			guard let patient = carePlan.patients?.first else {
				XCTFail("No patients found in careplan")
				return
			}
			let ockPatient = OCKPatient(patient: patient)
			let add = expectation(description: "DefaultCarePlan")
			careManager.store.createOrUpdatePatient(ockPatient, callbackQueue: .main) { result in
				switch result {
				case .failure(let error):
					XCTFail("Error inserting DefaultDiabetes Care Plan = \(error.localizedDescription)")
				case .success(let newPatient):
					ALog.info("\(newPatient.id), \(newPatient.uuid), \(newPatient.updatedDate)")
					add.fulfill()
				}
			}
			XCTAssertEqual(.completed, XCTWaiter().wait(for: [add], timeout: 10))
		}
	}
}
