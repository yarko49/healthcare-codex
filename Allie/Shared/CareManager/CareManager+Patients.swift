//
//  CareManager+Patients.swift
//  Allie
//
//  Created by Waqar Malik on 9/11/21.
//

import CareKitStore
import CareModel
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
