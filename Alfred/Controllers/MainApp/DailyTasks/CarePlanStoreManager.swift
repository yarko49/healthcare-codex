//
//  CarePlanStoreManager.swift
//  Alfred
//
//  Created by Waqar Malik on 11/23/20.
//

import CareKit
import CareKitStore
import Combine
import FirebaseAuth
import Foundation

class CarePlanStoreManager: ObservableObject {
	typealias BoolCompletion = (Bool) -> Void

	enum Constants {
		static let careKitTasksStore = "TasksStore"
		static let healthKitPassthroughStore = "HealthKitPassthroughStore"
		static let coreDataStoreType: OCKCoreDataStoreType = .inMemory
	}

	private(set) lazy var remoteSynchronizationManager: RemoteSynchronizationManager = {
		let manager = RemoteSynchronizationManager()
		manager.delegate = self
		return manager
	}()

	private(set) lazy var healthKitPassthroughStore = OCKHealthKitPassthroughStore(name: Constants.healthKitPassthroughStore, type: Constants.coreDataStoreType)
	private(set) lazy var store = OCKStore(name: Constants.careKitTasksStore, type: Constants.coreDataStoreType, remote: remoteSynchronizationManager)
	private(set) lazy var synchronizedStoreManager: OCKSynchronizedStoreManager = {
		let coordinator = OCKStoreCoordinator()
		coordinator.attach(store: store)
		coordinator.attach(eventStore: healthKitPassthroughStore)
		let manager = OCKSynchronizedStoreManager(wrapping: coordinator)
		return manager
	}()
}

// MARK: - CarePlanResponse

extension CarePlanStoreManager {
	func insert(carePlansResponse: CarePlanResponse, for patient: OCKPatient?, completion: OCKResultClosure<[String]>?) {
		var identifiers: [String] = []
		let ockTasks = carePlansResponse.allTasks.map { (task) -> OCKTask in
			identifiers.append(task.id)
			return OCKTask(task: task)
		}
		store.addAnyTasks(ockTasks, callbackQueue: .main) { result in
			switch result {
			case .failure(let error):
				completion?(.failure(error))
			case .success:
				completion?(.success(identifiers))
			}
		}
	}

	static func carePlanResponse(contentsOf name: String, withExtension: String) -> CarePlanResponse? {
		guard let fileURL = Bundle.main.url(forResource: name, withExtension: withExtension) else {
			return nil
		}
		do {
			let data = try Data(contentsOf: fileURL)
			let carePlanResponse = try CHJSONDecoder().decode(CarePlanResponse.self, from: data)
			return carePlanResponse
		} catch {
			ALog.info("\(error.localizedDescription)")
			return nil
		}
	}

	static func carePlanResponse(name: String, withExtension: String, completion: OCKResultClosure<CarePlanResponse>?) {
		guard let fileURL = Bundle.main.url(forResource: name, withExtension: withExtension) else {
			completion?(.failure(.fetchFailed(reason: "File does not exists \(name).\(withExtension)")))
			return
		}
		do {
			let data = try Data(contentsOf: fileURL)
			let carePlanResponse = try CHJSONDecoder().decode(CarePlanResponse.self, from: data)
			completion?(.success(carePlanResponse))
		} catch {
			ALog.info("\(error.localizedDescription)")
			completion?(.failure(.fetchFailed(reason: error.localizedDescription)))
		}
	}

	static func carePlanResponseFromServer(completion: OCKResultClosure<CarePlanResponse>?) {
		AlfredClient.client.getCarePlan { result in
			switch result {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
				completion?(.failure(.fetchFailed(reason: error.localizedDescription)))
			case .success(let carePlanResponse):
				completion?(.success(carePlanResponse))
			}
		}
	}
}

// MARK: - CarePlan

extension CarePlanStoreManager {
	func createOrUpdate(newCarePlans: [OCKCarePlan], for patient: OCKPatient?, completion: OCKResultClosure<[OCKCarePlan]>?) {
		let dispatchGroup = DispatchGroup()
		var plans: [OCKCarePlan] = []
		for plan in newCarePlans {
			dispatchGroup.enter()
			createOrUpdate(newCarePlan: plan) { result in
				switch result {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
				case .success(var newCarePlan):
					newCarePlan.patientUUID = patient?.uuid
					plans.append(newCarePlan)
				}
				dispatchGroup.leave()
			}
		}

		dispatchGroup.notify(queue: .main) {
			completion?(.success(plans))
		}
	}

	func createOrUpdate(newCarePlan: OCKCarePlan, completion: OCKResultClosure<OCKCarePlan>?) {
		store.fetchCarePlan(withID: newCarePlan.id) { [weak self] fetchResult in
			switch fetchResult {
			case .failure:
				self?.store.addCarePlan(newCarePlan, completion: completion)
			case .success:
				self?.store.updateCarePlan(newCarePlan, completion: completion)
			}
		}
	}
}

// MARK: - Tasks

extension CarePlanStoreManager {
	func createOrUpdate(newTasks: [OCKTask], for carePlan: OCKCarePlan?, completion: OCKResultClosure<[OCKTask]>?) {
		let dispatchGroup = DispatchGroup()
		var tasks: [OCKTask] = []
		for var task in newTasks {
			dispatchGroup.enter()
			if let plan = carePlan {
				task.carePlanUUID = plan.uuid
			}
			createOrUpdate(newTask: task) { result in
				switch result {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
				case .success(let newTask):
					tasks.append(newTask)
				}
				dispatchGroup.leave()
			}
		}

		dispatchGroup.notify(queue: .main) {
			completion?(.success(tasks))
		}
	}

	func createOrUpdate(newTask: OCKTask, completion: OCKResultClosure<OCKTask>?) {
		store.fetchTask(withID: newTask.id) { [weak self] result in
			switch result {
			case .failure:
				self?.store.addTask(newTask, completion: completion)
			case .success:
				self?.store.updateTask(newTask, completion: completion)
			}
		}
	}
}

// MARK: - Patients

extension CarePlanStoreManager {
	func createOrUpdate(newPatients: [OCKPatient], completion: OCKResultClosure<[OCKPatient]>?) {
		let dispatchGroup = DispatchGroup()
		var patients: [OCKPatient] = []
		for patient in newPatients {
			dispatchGroup.enter()
			createOrUpdate(newPatient: patient) { result in
				switch result {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
				case .success(let newCarePlan):
					patients.append(newCarePlan)
				}
				dispatchGroup.leave()
			}
		}

		dispatchGroup.notify(queue: .main) {
			completion?(.success(patients))
		}
	}

	func createOrUpdate(newPatient: OCKPatient, completion: OCKResultClosure<OCKPatient>?) {
		store.fetchPatient(withID: newPatient.id) { [weak self] result in
			switch result {
			case .failure:
				self?.store.addPatient(newPatient, completion: completion)
			case .success:
				self?.store.updatePatient(newPatient, completion: completion)
			}
		}
	}

	func createPatientFromServer(user: RemoteUser?, completion: OCKResultClosure<OCKPatient>?) {
		AlfredClient.client.postPatientSearch { [weak self] result in
			switch result {
			case .success(let response):
				guard let resource = response.entry?.first?.resource else {
					completion?(.failure(.fetchFailed(reason: "Server did not return patient")))
					return
				}

				guard let newPatient = OCKPatient(resource: resource, user: user) else {
					completion?(.failure(.updateFailed(reason: "Unable to create patient")))
					return
				}
				self?.createOrUpdate(newPatient: newPatient, completion: completion)
			case .failure(let error):
				ALog.error("Patient Search \(error.localizedDescription)")
				completion?(.failure(.remoteSynchronizationFailed(reason: error.localizedDescription)))
			}
		}
	}
}

// MARK: - OCKRemoteSynchronizationDelegate

extension CarePlanStoreManager: OCKRemoteSynchronizationDelegate {
	public func didRequestSynchronization(_ remote: OCKRemoteSynchronizable) {
		ALog.info("Did Request Synchronization")
	}

	public func remote(_ remote: OCKRemoteSynchronizable, didUpdateProgress progress: Double) {
		ALog.info("Did Update Progress")
	}
}
