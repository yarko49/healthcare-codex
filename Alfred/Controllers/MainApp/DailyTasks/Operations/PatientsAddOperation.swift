//
//  PatientsAddOperation.swift
//  Alfred
//
//  Created by Waqar Malik on 1/15/21.
//

import CareKitStore
import Foundation

protocol PatientsResultProvider {
	var patients: [OCKPatient]? { get }
}

class PatientsAddOperation: AsynchronousOperation, PatientsResultProvider {
	var patients: [OCKPatient]?

	private var store: OCKStore
	private var newPatients: [OCKPatient]
	private var completionHandler: OCKResultClosure<[OCKPatient]>?

	init(store: OCKStore, newPatients: [OCKPatient] = [], callbackQueue: DispatchQueue = .main, completion: OCKResultClosure<[OCKPatient]>? = nil) {
		self.store = store
		self.newPatients = newPatients
		self.completionHandler = completion
		super.init()
		self.callbackQueue = callbackQueue
	}

	private var error: OCKStoreError?

	override func main() {
		guard !newPatients.isEmpty else {
			complete()
			return
		}
		store.createOrUpdatePatients(newPatients, callbackQueue: callbackQueue) { [weak self] result in
			defer {
				self?.complete()
			}

			switch result {
			case .failure(let error):
				self?.error = error
			case .success(let addedResults):
				self?.patients = addedResults
			}
		}
	}

	private func complete() {
		guard let handler = completionHandler else {
			finish()
			return
		}
		callbackQueue.async { [weak self] in
			if let results = self?.patients, self?.error == nil {
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
