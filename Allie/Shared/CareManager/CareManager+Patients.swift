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

	func loadPatient() async throws -> OCKPatient {
		let patients = try await store.fetchPatients(query: OCKPatientQuery(for: Date()))
		let sorted = patients.sorted { lhs, rhs in
			guard let ldate = lhs.updatedDate, let rdate = rhs.updatedDate else {
				return false
			}
			return ldate < rdate
		}
		guard let lastItem = sorted.last else {
			throw OCKStoreError.fetchFailed(reason: "No patients in the store")
		}
		return lastItem
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

	func findPatient(identifier: String) async throws -> OCKPatient {
		try await store.fetchPatient(withID: identifier)
	}

	func findOrCreate(user: RemoteUser) async throws -> OCKPatient {
		do {
			let patient = try await findPatient(identifier: user.uid)
			return patient
		} catch {
			let patient = try OCKPatient(remoteUser: user)
			return try await store.addPatient(patient)
		}
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
