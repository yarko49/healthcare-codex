//
//  CarePlansAddOperation.swift
//  Alfred
//
//  Created by Waqar Malik on 1/15/21.
//

import CareKitStore
import Foundation

protocol CarePlansResultProvider {
	var carePlans: [OCKCarePlan]? { get }
}

class CarePlansAddOperation: AsynchronousOperation, CarePlansResultProvider {
	var carePlans: [OCKCarePlan]?

	private var store: OCKStore
	private var newCarePlans: [OCKCarePlan]
	private var completionHandler: OCKResultClosure<[OCKCarePlan]>?
	private var exisingPatient: OCKPatient?

	init(store: OCKStore, newCarePlans: [OCKCarePlan] = [], for patient: OCKPatient? = nil, callbackQueue: DispatchQueue = .main, completion: OCKResultClosure<[OCKCarePlan]>? = nil) {
		self.store = store
		self.newCarePlans = newCarePlans
		self.completionHandler = completion
		self.exisingPatient = patient
		super.init()
		self.callbackQueue = callbackQueue
	}

	private var error: OCKStoreError?

	override func main() {
		guard !newCarePlans.isEmpty else {
			complete()
			return
		}
		var mappedCarePlans = newCarePlans
		if let existingPatient = exisingPatient {
			mappedCarePlans = newCarePlans.map { (carePlan) -> OCKCarePlan in
				var plan = carePlan
				plan.patientUUID = existingPatient.uuid
				return plan
			}
		} else {
			let patientsFromDependency = dependencies.compactMap { (operation) -> [OCKPatient]? in
				(operation as? PatientsResultProvider)?.patients
			}.first?.first

			if let patient = patientsFromDependency {
				mappedCarePlans = newCarePlans.map { (carePlan) -> OCKCarePlan in
					var plan = carePlan
					plan.patientUUID = patient.uuid
					return plan
				}
			}
		}

		store.addCarePlans(mappedCarePlans, callbackQueue: callbackQueue) { [weak self] result in
			defer {
				self?.complete()
			}

			switch result {
			case .failure(let error):
				self?.error = error
			case .success(let addedResults):
				self?.carePlans = addedResults
			}
		}
	}

	private func complete() {
		guard let handler = completionHandler else {
			finish()
			return
		}
		callbackQueue.async { [weak self] in
			if let results = self?.carePlans, self?.error == nil {
				handler(.success(results))
			} else if let error = self?.error {
				handler(.failure(error))
			} else {
				handler(.failure(.addFailed(reason: "Invalid Input Data")))
			}
		}
		finish()
	}
}
