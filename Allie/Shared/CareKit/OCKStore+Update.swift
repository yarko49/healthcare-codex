//
//  OCKStore+Update.swift
//  Allie
//
//  Created by Waqar Malik on 2/2/21.
//

import CareKitStore
import Combine
import Foundation

// MARK: - Patients

extension OCKStore {
	func createOrUpdate(patient: OCKPatient, callbackQueue: DispatchQueue = .main, completion: ((Result<OCKPatient, OCKStoreError>) -> Void)? = nil) {
		fetchPatient(withID: patient.id) { [weak self] result in
			switch result {
			case .failure:
				self?.addPatient(patient, callbackQueue: callbackQueue, completion: completion)
			case .success(let existing):
				let merged = existing.merged(newPatient: patient)
				self?.updatePatient(merged, callbackQueue: callbackQueue, completion: completion)
			}
		}
	}

	func createOrUpdate(patients: [OCKPatient], callbackQueue: DispatchQueue = .main, completion: ((Result<[OCKPatient], OCKStoreError>) -> Void)? = nil) {
		guard !patients.isEmpty else {
			completion?(.failure(.updateFailed(reason: "Missing input patients")))
			return
		}
		let queue = DispatchQueue.global(qos: .userInitiated)
		var errors: [String: Error] = [:]
		var updatedPatients: [OCKPatient] = []
		queue.async { [weak self] in
			let group = DispatchGroup()
			for patient in patients {
				group.enter()
				self?.createOrUpdate(patient: patient, callbackQueue: queue) { result in
					switch result {
					case .failure(let error):
						errors[patient.id] = error
					case .success(let updated):
						updatedPatients.append(updated)
					}
					group.leave()
				}
			}
			group.notify(queue: callbackQueue) {
				completion?(.success(updatedPatients))
			}
		}
	}
}

// MARK: - CarePlans

extension OCKStore {
	func createOrUpdate(carePlan: OCKCarePlan, callbackQueue: DispatchQueue = .main, completion: ((Result<OCKCarePlan, OCKStoreError>) -> Void)? = nil) {
		fetchCarePlan(withID: carePlan.id, callbackQueue: callbackQueue) { [weak self] result in
			switch result {
			case .failure:
				self?.addCarePlan(carePlan, callbackQueue: callbackQueue, completion: completion)
			case .success(let existing):
				let merged = existing.merged(newCarePlan: carePlan)
				self?.updateCarePlan(merged, callbackQueue: callbackQueue, completion: completion)
			}
		}
	}

	func createOrUpdate(carePlans: [OCKCarePlan], callbackQueue: DispatchQueue = .main, completion: ((Result<[OCKCarePlan], OCKStoreError>) -> Void)? = nil) {
		guard !carePlans.isEmpty else {
			completion?(.failure(.updateFailed(reason: "Missing input care plans")))
			return
		}
		let queue = DispatchQueue.global(qos: .userInitiated)
		var errors: [String: Error] = [:]
		var updatedCarePlans: [OCKCarePlan] = []
		queue.async { [weak self] in
			let group = DispatchGroup()
			for carePlan in carePlans {
				group.enter()
				self?.createOrUpdate(carePlan: carePlan, callbackQueue: queue, completion: { result in
					switch result {
					case .failure(let error):
						errors[carePlan.id] = error
					case .success(let updated):
						updatedCarePlans.append(updated)
					}
					group.leave()
				})
			}
			group.notify(queue: callbackQueue) {
				completion?(.success(updatedCarePlans))
			}
		}
	}
}

// MARK: - Tasks

extension OCKStore {
	func createOrUpdate(task: OCKTask, callbackQueue: DispatchQueue = .main, completion: ((Result<OCKTask, OCKStoreError>) -> Void)? = nil) {
		fetchTask(withID: task.id, callbackQueue: callbackQueue) { [weak self] result in
			switch result {
			case .failure:
				self?.addTask(task, callbackQueue: callbackQueue, completion: completion)
			case .success(let existing):
				let merged = existing.merged(new: task)
				self?.updateTask(merged, callbackQueue: callbackQueue, completion: completion)
			}
		}
	}

	func createOrUpdate(tasks: [OCKTask], callbackQueue: DispatchQueue = .main, completion: ((Result<[OCKTask], OCKStoreError>) -> Void)? = nil) {
		guard !tasks.isEmpty else {
			completion?(.failure(.updateFailed(reason: "Missing input tasks")))
			return
		}

		let queue = DispatchQueue.global(qos: .userInitiated)
		var errors: [String: Error] = [:]
		var updatedTasks: [OCKTask] = []
		queue.async { [weak self] in
			let group = DispatchGroup()
			for task in tasks {
				group.enter()
				self?.createOrUpdate(task: task, callbackQueue: queue, completion: { result in
					switch result {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
						errors[task.id] = error
					case .success(let updated):
						updatedTasks.append(updated)
					}
					group.leave()
				})
			}
			group.notify(queue: callbackQueue) {
				completion?(.success(updatedTasks))
			}
		}
	}
}

// MARK: - Outcomes

extension OCKStore {
	func createOrUpdate(outcome: OCKOutcome, callbackQueue: DispatchQueue = .main, completion: ((Result<OCKOutcome, OCKStoreError>) -> Void)? = nil) {
		var query = OCKOutcomeQuery()
		query.uuids.append(outcome.uuid)
		fetchOutcomes(query: query, callbackQueue: callbackQueue) { [weak self] result in
			switch result {
			case .failure:
				self?.addOutcome(outcome, callbackQueue: callbackQueue, completion: completion)
			case .success(let existingOutcomes):
				if let first = existingOutcomes.first {
					let merged = first.merged(newOutcome: outcome)
					self?.updateOutcome(merged, callbackQueue: callbackQueue, completion: completion)
				} else {
					self?.addOutcome(outcome, callbackQueue: callbackQueue, completion: completion)
				}
			}
		}
	}

	func createOrUpdate(outcomes: [OCKOutcome], callbackQueue: DispatchQueue = .main, completion: ((Result<[OCKOutcome], OCKStoreError>) -> Void)? = nil) {
		guard !outcomes.isEmpty else {
			completion?(.failure(.updateFailed(reason: "Missing input outcomes")))
			return
		}

		let queue = DispatchQueue.global(qos: .userInitiated)
		var errors: [String: Error] = [:]
		var updatedOutcomes: [OCKOutcome] = []
		queue.async { [weak self] in
			let group = DispatchGroup()
			for outcome in outcomes {
				group.enter()
				self?.createOrUpdate(outcome: outcome, callbackQueue: queue, completion: { result in
					switch result {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
						errors[outcome.id] = error
					case .success(let updated):
						updatedOutcomes.append(updated)
					}
					group.leave()
				})
			}
			group.notify(queue: callbackQueue) {
				if updatedOutcomes.isEmpty {
					completion?(.failure(.updateFailed(reason: "Unable to add to store")))
				} else {
					completion?(.success(updatedOutcomes))
				}
			}
		}
	}
}
