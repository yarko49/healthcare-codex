//
//  CareManager+Patients.swift
//  Allie
//
//  Created by Waqar Malik on 9/11/21.
//

import CareKitStore
import Combine
import Foundation

extension CareManager {
	func upload(patient: CHPatient) {
		networkAPI.post(patient: patient)
			.sink { completionResult in
				if case .failure(let error) = completionResult {
					ALog.error("Unable to upload patient", error: error)
				}
			} receiveValue: { carePlanResponse in
				let id = carePlanResponse.patients.active.first?.id ?? "Unkown Id"
				ALog.info("Did upload patient \(id)")
			}.store(in: &cancellables)
	}

	func process(patient: CHPatient) async throws -> CHPatient {
		var updatePatient = patient
		let ockPatient = OCKPatient(patient: patient)
		do {
			let existingPatient = try await store.fetchPatient(withID: updatePatient.id)
			let updated = existingPatient.merged(newPatient: ockPatient)
			let newPatient = try await store.updatePatient(updated)
			updatePatient.uuid = newPatient.uuid
		} catch {
			let newPatient = try await store.addPatient(ockPatient)
			updatePatient.uuid = newPatient.uuid
		}
		return updatePatient
	}

	func loadPatient(completion: OCKResultClosure<OCKPatient>?) {
		store.fetchPatients { result in
			switch result {
			case .failure(let error):
				completion?(.failure(error))
			case .success(let patients):
				let sorted = patients.sorted { lhs, rhs in
					guard let ldate = lhs.updatedDate, let rdate = rhs.updatedDate else {
						return false
					}
					return ldate < rdate
				}
				if let patient = sorted.last {
					completion?(.success(patient))
				} else {
					completion?(.failure(.fetchFailed(reason: "No patients in the store")))
				}
			}
		}
	}

	func findPatient(identifier: String) -> Future<OCKPatient, Error> {
		Future { [weak self] promise in
			self?.store.fetchPatient(withID: identifier, callbackQueue: .main) { result in
				switch result {
				case .failure(let error):
					promise(.failure(error))
				case .success(let anyPatient):
					let patient = anyPatient as OCKPatient
					promise(.success(patient))
				}
			}
		}
	}

	func findPatient(identifier: String, completion: OCKResultClosure<OCKPatient>?) {
		store.fetchPatient(withID: identifier, callbackQueue: .main) { result in
			switch result {
			case .failure(let error):
				completion?(.failure(error))
			case .success(let patient):
				let ockPatient = patient as OCKPatient
				completion?(.success(ockPatient))
			}
		}
	}

	func findOrCreate(user: RemoteUser, completion: OCKResultClosure<OCKPatient>?) {
		findPatient(identifier: user.uid)
			.sink { [weak self] completionResult in
				switch completionResult {
				case .failure:
					guard let patient = OCKPatient(user: user) else {
						completion?(.failure(.addFailed(reason: "Invalid Input")))
						return
					}
					self?.store.addPatient(patient, completion: completion)
				case .finished:
					break
				}
			} receiveValue: { patient in
				completion?(.success(patient))
			}.store(in: &cancellables)
	}

	func process(patient: OCKPatient, completion: OCKResultClosure<OCKPatient>?) {
		store.process(patient: patient, callbackQueue: .main) { result in
			switch result {
			case .failure(let error):
				completion?(.failure(error))
			case .success(let patient):
				completion?(.success(patient))
			}
		}
	}
}
