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

	private(set) lazy var healthKitStore = OCKHealthKitPassthroughStore(name: Constants.healthKitPassthroughStore, type: Constants.coreDataStoreType)
	private(set) lazy var store = OCKStore(name: Constants.careKitTasksStore, type: Constants.coreDataStoreType, remote: remoteSynchronizationManager)
	private(set) lazy var synchronizedStoreManager: OCKSynchronizedStoreManager = {
		let coordinator = OCKStoreCoordinator()
		coordinator.attach(store: store)
		coordinator.attach(eventStore: healthKitStore)
		let manager = OCKSynchronizedStoreManager(wrapping: coordinator)
		return manager
	}()

	private var storeOperationQueue: OperationQueue = {
		let queue = OperationQueue()
		queue.qualityOfService = .utility
		queue.maxConcurrentOperationCount = 1
		return queue
	}()

	@Published var patient: OCKPatient? {
		willSet {
			objectWillChange.send()
			ALog.info("Did Create a patient \(String(describing: patient))")
		}
	}

	private var cancellables: Set<AnyCancellable> = []

	init() {
		DataContext.shared.$resouce.sink { [weak self] newValue in
			guard let resource = newValue, let user = Auth.auth().currentUser, let patient = OCKPatient(id: nil, resource: resource, user: user) else {
				return
			}
			self?.addPatients(newPatients: [patient], completion: { result in
				switch result {
				case .failure(let error):
					ALog.error(error: error)
				case .success(let storePatient):
					self?.patient = storePatient.first
				}
			})
		}.store(in: &cancellables)
	}
}

// MARK: - CarePlanResponse

extension CarePlanStoreManager {
	func insert(carePlansResponse: CarePlanResponse, for patient: OCKPatient?, completion: OCKResultClosure<[String]>?) {
		let carePlans = carePlansResponse.carePlans.values.compactMap { (plan) -> OCKCarePlan in
			OCKCarePlan(carePlan: plan)
		}

		let addCarePlansOperation = CarePlansAddOperation(store: store, newCarePlans: carePlans, for: patient)
		if let patient = patient, patient.uuid == nil {
			let patientOperation = PatientsAddOperation(store: store, newPatients: [patient]) { [weak self] result in
				switch result {
				case .failure(let error):
					ALog.error(error: error)
				case .success(let newPatients):
					self?.patient = newPatients.first
				}
			}
			addCarePlansOperation.addDependency(patientOperation)
			storeOperationQueue.addOperation(patientOperation)
		}

		storeOperationQueue.addOperation(addCarePlansOperation)

		let allTasks = carePlansResponse.allTasks.map { (task) -> OCKAnyTask in
			task.ockTask
		}

		let healthKitTasks = allTasks.compactMap { (task) -> OCKHealthKitTask? in
			task as? OCKHealthKitTask
		}

		let careTasks = allTasks.compactMap { (task) -> OCKTask? in
			task as? OCKTask
		}

		let tasksOperation = TasksAddOperation(store: store, newTasks: careTasks)
		tasksOperation.addDependency(addCarePlansOperation)

		let healthKitTasksOperation = HealthKitAddTasksOperation(store: healthKitStore, newTasks: healthKitTasks) { result in
			switch result {
			case .failure(let error):
				completion?(.failure(error))
			case .success:
				completion?(.success([]))
			}
		}

		healthKitTasksOperation.addDependency(tasksOperation)
		storeOperationQueue.addOperation(tasksOperation)
		storeOperationQueue.addOperation(healthKitTasksOperation)
	}

	class func getCarePlan(completion: OCKResultClosure<CarePlanResponse>?) {
		AlfredClient.client.getCarePlan { result in
			switch result {
			case .failure(let error):
				ALog.error(error: error)
				completion?(.failure(.fetchFailed(reason: error.localizedDescription)))
			case .success(let carePlanResponse):
				completion?(.success(carePlanResponse))
			}
		}
	}
}

// MARK: - Patients

extension CarePlanStoreManager {
	class func getPatient(user: RemoteUser?, completion: OCKResultClosure<OCKPatient>?) {
		AlfredClient.client.postPatientSearch { result in
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
				completion?(.success(newPatient))
			case .failure(let error):
				ALog.error("Patient Search", error: error)
				completion?(.failure(.remoteSynchronizationFailed(reason: error.localizedDescription)))
			}
		}
	}

	func addPatients(newPatients: [OCKPatient], completion: OCKResultClosure<[OCKPatient]>?) {
		let addPatientOperation = PatientsAddOperation(store: store, newPatients: newPatients, completion: completion)
		storeOperationQueue.addOperation(addPatientOperation)
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
