//
//  OCKStore+Update.swift
//  Allie
//
//  Created by Waqar Malik on 2/2/21.
//

import CareKitStore
import Foundation

extension OCKStore {
	func createOrUpdatePatient(_ patient: OCKPatient, callbackQueue: DispatchQueue = .main, completion: ((Result<OCKPatient, OCKStoreError>) -> Void)? = nil) {
		addPatient(patient, callbackQueue: callbackQueue) { [weak self] result in
			if case .success(let addPatient) = result {
				completion?(.success(addPatient))
			} else {
				self?.updatePatient(patient, callbackQueue: callbackQueue, completion: completion)
			}
		}
	}

	func createOrUpdatePatients(_ patients: [OCKPatient], callbackQueue: DispatchQueue = .main, completion: ((Result<[OCKPatient], OCKStoreError>) -> Void)? = nil) {
		let queue = DispatchQueue.global(qos: .background)
		var errors: [String: Error] = [:]
		var updatedPatients: [OCKPatient] = []
		queue.async { [weak self] in
			let group = DispatchGroup()
			for patient in patients {
				group.enter()
				self?.createOrUpdatePatient(patient, callbackQueue: queue) { result in
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

	func createOrUpdateCarePlan(_ carePlan: OCKCarePlan, callbackQueue: DispatchQueue = .main, completion: ((Result<OCKCarePlan, OCKStoreError>) -> Void)? = nil) {
		addCarePlan(carePlan, callbackQueue: callbackQueue) { [weak self] result in
			if case .success(let addCarePlan) = result {
				completion?(.success(addCarePlan))
			} else {
				self?.updateCarePlan(carePlan, callbackQueue: callbackQueue, completion: completion)
			}
		}
	}

	func createOrUpdateCarePlans(_ carePlans: [OCKCarePlan], callbackQueue: DispatchQueue = .main, completion: ((Result<[OCKCarePlan], OCKStoreError>) -> Void)? = nil) {
		let queue = DispatchQueue.global(qos: .background)
		var errors: [String: Error] = [:]
		var updatedCarePlans: [OCKCarePlan] = []
		queue.async { [weak self] in
			let group = DispatchGroup()
			for carePlan in carePlans {
				group.enter()
				self?.createOrUpdateCarePlan(carePlan, callbackQueue: queue, completion: { result in
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

	func createOrUpdateTask(_ task: OCKTask, callbackQueue: DispatchQueue = .main, completion: ((Result<OCKTask, OCKStoreError>) -> Void)? = nil) {
		addTask(task, callbackQueue: callbackQueue) { [weak self] result in
			if case .success(let addedTask) = result {
				completion?(.success(addedTask))
			} else {
				self?.updateTask(task, callbackQueue: callbackQueue, completion: completion)
			}
		}
	}

	func createOrUpdateTasks(_ tasks: [OCKTask], callbackQueue: DispatchQueue = .main, completion: ((Result<[OCKTask], OCKStoreError>) -> Void)? = nil) {
		let queue = DispatchQueue.global(qos: .background)
		var errors: [String: Error] = [:]
		var updatedTasks: [OCKTask] = []
		queue.async { [weak self] in
			let group = DispatchGroup()
			for task in tasks {
				group.enter()
				self?.createOrUpdateTask(task, callbackQueue: queue, completion: { result in
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
