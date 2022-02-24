//
//  CareKitStoreTests.swift
//  AllieTests
//
//  Created by Waqar Malik on 3/16/21.
//

@testable import Allie
import CareKitStore
import Combine
import ModelsR4
import XCTest

class CareKitStoreTests: XCTestCase {
	let careManager = CareManager.shared
	var client: APIClient?
	var cancellables: Set<AnyCancellable> = []

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

	func testLoadAllPatient() throws {
		let expect = expectation(description: "Load Patient")
		careManager.store.fetchPatients { result in
			switch result {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
			case .success(let patients):
				patients.forEach { patient in
					ALog.info("\(patient.id), \(String(describing: patient.createdDate)), \(String(describing: patient.updatedDate)), \(String(describing: patient.deletedDate)), \(patient.effectiveDate)")
				}
				expect.fulfill()
			}
		}
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testGetPatientFromServer() throws {
		let carePlanResponse = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(carePlanResponse)
		let url = try APIRouter.getCarePlan(option: .carePlan).url()
		XCTAssert(!carePlanResponse!.isEmpty)
		URLProtocolMock.testData[url] = carePlanResponse
		URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
		let expect = expectation(description: "DefaultCarePlan")
		client?.getCarePlan()
			.sink(receiveCompletion: { result in
				if case .failure(let error) = result {
					XCTFail("Error Fetching DefaultDiabetes Care Plan = \(error.localizedDescription)")
					URLProtocolMock.response = nil
				}
			}, receiveValue: { carePlanResponse in
				let patients = carePlanResponse.patients
				XCTAssertNotNil(patients)
				XCTAssertEqual(patients.count, 1)
				let patient = patients.active.first
				XCTAssertNotNil(patient)
				XCTAssertNotNil(patient?.profile.fhirId)
				expect.fulfill()
				URLProtocolMock.response = nil
			}).store(in: &cancellables)
		XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 10))
	}

	func testInsertCarePlanFromServer() async throws {
		let carePlanResponseData = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(carePlanResponseData)
		let url = try APIRouter.getCarePlan(option: .carePlan).url()
		XCTAssert(!carePlanResponseData!.isEmpty)
		URLProtocolMock.testData[url] = carePlanResponseData
		URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
		let carePlanResponse = try await client?.getCarePlan(option: .carePlan)
		XCTAssertNotNil(carePlanResponse)
		_ = try await careManager.process(carePlanResponse: carePlanResponse!)
	}

	func testInsertPatients() async throws {
		let carePlanResponseData = AllieTests.loadTestData(fileName: "DiabetiesCarePlan.json")
		XCTAssertNotNil(carePlanResponseData)
		let url = try APIRouter.getCarePlan(option: .carePlan).url()
		XCTAssert(!carePlanResponseData!.isEmpty)
		URLProtocolMock.testData[url] = carePlanResponseData
		URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
		let carePlanRespons = try await client?.getCarePlan(option: .carePlan)

		if let carePlan = carePlanRespons {
			guard let patient = carePlan.patients.active.first else {
				XCTFail("No patients found in careplan")
				return
			}
			let ockPatient = OCKPatient(patient: patient)
			let add = expectation(description: "DefaultCarePlan")
			careManager.store.process(patient: ockPatient, callbackQueue: .main, completion: { result in
				switch result {
				case .failure(let error):
					XCTFail("Error inserting DefaultDiabetes Care Plan = \(error.localizedDescription)")
				case .success(let newPatient):
					ALog.info("\(newPatient.id), \(newPatient.uuid), \(String(describing: newPatient.updatedDate))")
					add.fulfill()
				}
			})
			XCTAssertEqual(.completed, XCTWaiter().wait(for: [add], timeout: 10))
		}
	}
}
