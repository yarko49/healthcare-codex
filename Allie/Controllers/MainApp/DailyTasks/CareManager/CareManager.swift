//
//  CareManager.swift
//  Allie
//
//  Created by Waqar Malik on 11/23/20.
//

import CareKit
import CareKitFHIR
import CareKitStore
import Combine
import FirebaseAuth
import Foundation
import ModelsR4

class CareManager: ObservableObject {
	typealias BoolCompletion = (Bool) -> Void

	enum Constants {
		static let careStore = "CareStore"
		static let healthKitPassthroughStore = "HealthKitPassthroughStore"
		static let coreDataStoreType: OCKCoreDataStoreType = .onDisk(protection: .completeUnlessOpen)
	}

	private(set) lazy var remoteSynchronizationManager: RemoteSynchronizationManager = {
		let manager = RemoteSynchronizationManager(automaticallySynchronizes: false)
		manager.delegate = self
		return manager
	}()

	private(set) lazy var store = OCKStore(name: Constants.careStore, type: Constants.coreDataStoreType, remote: remoteSynchronizationManager)
	private(set) lazy var healthKitStore = OCKHealthKitPassthroughStore(store: store)
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

	@Published var patient: OCKPatient?
	private var cancellables: Set<AnyCancellable> = []
	@Published var vectorClock: [String: Int] = [:]
	@Published var provider: String = "CodexPilotHealthcareOrganization"

	init() {
		store.resetDelegate = self
		healthKitStore.resetDelegate = self
	}
}

// MARK: - CarePlanResponse

extension CareManager {
	func insert(carePlansResponse: CarePlanResponse, for patient: OCKPatient?, completion: OCKResultClosure<Bool>?) {
		let carePlans = carePlansResponse.allCarePlans.map { (carePlan) -> OCKCarePlan in
			OCKCarePlan(carePlan: carePlan)
		}

		let addCarePlansOperation = CarePlansAddOperation(store: store, newCarePlans: carePlans, for: patient)
		if let patient = patient {
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
				completion?(.success(true))
			}
		}

		healthKitTasksOperation.addDependency(addCarePlansOperation)
		storeOperationQueue.addOperation(tasksOperation)
		storeOperationQueue.addOperation(healthKitTasksOperation)
	}

	class func getCarePlan(completion: OCKResultClosure<CarePlanResponse>?) {
		APIClient.client.getCarePlan { result in
			switch result {
			case .failure(let error):
				ALog.error(error: error)
				completion?(.failure(.fetchFailed(reason: error.localizedDescription)))
			case .success(let carePlanResponse):
				completion?(.success(carePlanResponse))
			}
		}
	}

	class func postPatient(patient: OCKPatient, completion: @escaping WebService.RequestCompletion<[String: Any]>) {
		let alliePatient = AlliePatient(ockPatient: patient)
		APIClient.client.postPatient(patient: alliePatient, completion: completion)
	}

	class func register(provider: String) {
		APIClient.client.registerProvider(identifier: provider) { result in
			switch result {
			case .failure(let error):
				ALog.error("Unable to register healthcare provider \(error.localizedDescription)")
			case .success:
				ALog.info("Did Register the provider \(provider)")
			}
		}
	}
}

// MARK: - Patients

extension CareManager {
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
		findPatient(identifier: user.uid) { [weak self] result in
			switch result {
			case .success(let patient):
				completion?(.success(patient))
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
				guard let patient = OCKPatient(user: user) else {
					completion?(.failure(.addFailed(reason: "Invalid Input")))
					return
				}
				self?.store.addPatient(patient, completion: completion)
			}
		}
	}

	func createOrUpdate(patient: OCKPatient, completion: OCKResultClosure<OCKPatient>?) {
		store.createOrUpdatePatient(patient) { [weak self] result in
			switch result {
			case .failure(let error):
				completion?(.failure(error))
			case .success(let patient):
				self?.patient = patient
				completion?(.success(patient))
			}
		}
	}

	func addPatients(newPatients: [OCKPatient], completion: OCKResultClosure<[OCKPatient]>?) {
		let addPatientOperation = PatientsAddOperation(store: store, newPatients: newPatients, completion: completion)
		storeOperationQueue.addOperation(addPatientOperation)
	}
}

// MARK: - Reset

extension CareManager {
	func resetAllContents() throws {
		try store.reset()
		try healthKitStore.reset()
	}
}

// MARK: - OCKRemoteSynchronizationDelegate

extension CareManager: OCKRemoteSynchronizationDelegate {
	public func didRequestSynchronization(_ remote: OCKRemoteSynchronizable) {
		ALog.info("Did Request Synchronization")
	}

	public func remote(_ remote: OCKRemoteSynchronizable, didUpdateProgress progress: Double) {
		ALog.info("Did Update Progress")
	}
}

extension CareManager: OCKResetDelegate {
	func storeDidReset(_ store: OCKAnyResettableStore) {
		ALog.info("Store \(store) did reset")
	}
}
