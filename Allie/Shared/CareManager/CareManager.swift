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

	private var cancellables: Set<AnyCancellable> = []

	@Published var patient: AlliePatient? {
		didSet {
			if let value = patient {
				Keychain.save(patient: value)
			}
		}
	}

	@Published var vectorClock: [String: Int] = [:]

	init() {
		store.resetDelegate = self
		healthKitStore.resetDelegate = self
	}
}

// MARK: - CarePlanResponse

extension CareManager {
	func insert(carePlansResponse: CarePlanResponse, completion: OCKResultClosure<Bool>?) {
		try? resetAllContents()
		var newPatient: OCKPatient?
		if let thePatient = carePlansResponse.patients?.first {
			patient = thePatient
			newPatient = OCKPatient(patient: thePatient)
		}

		let carePlans = carePlansResponse.carePlans.map { (carePlan) -> OCKCarePlan in
			OCKCarePlan(carePlan: carePlan)
		}

		let addCarePlansOperation = CarePlansAddOperation(store: store, newCarePlans: carePlans, for: nil) { result in
			switch result {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
			case .success(let carePlans):
				ALog.info("carePlans count = \(carePlans.count)")
			}
		}

		if let patient = newPatient {
			let patientOperation = PatientsAddOperation(store: store, newPatients: [patient]) { result in
				switch result {
				case .failure(let error):
					ALog.error(error: error)
				case .success(let newPatients):
					ALog.info("Patient Count = \(newPatients.count)")
				}
			}
			addCarePlansOperation.addDependency(patientOperation)
			storeOperationQueue.addOperation(patientOperation)
		}

		storeOperationQueue.addOperation(addCarePlansOperation)

		let allTasks = carePlansResponse.tasks.map { (task) -> OCKAnyTask in
			task.ockTask
		}

		let healthKitTasks = allTasks.compactMap { (task) -> OCKHealthKitTask? in
			task as? OCKHealthKitTask
		}

		let careTasks = allTasks.compactMap { (task) -> OCKTask? in
			task as? OCKTask
		}

		let tasksOperation = TasksAddOperation(store: store, newTasks: careTasks) { result in
			switch result {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
			case .success(let tasks):
				ALog.info("tasks count = \(tasks.count)")
			}
		}
		tasksOperation.addDependency(addCarePlansOperation)

		let healthKitTasksOperation = HealthKitAddTasksOperation(store: healthKitStore, newTasks: healthKitTasks) { result in
			switch result {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
				completion?(.failure(error))
			case .success(let tasks):
				ALog.info("HK tasks count = \(tasks.count)")
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

	class func postPatient(patient: AlliePatient) -> Future<CarePlanResponse, Error> {
		APIClient.client.postPatient(patient: patient)
	}

	class func register(provider: String) -> Future<Bool, Never> {
		APIClient.client.regiterProvider(identifier: provider)
	}
}

// MARK: - Patients

extension CareManager {
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

	func createOrUpdate(patient: OCKPatient, completion: OCKResultClosure<OCKPatient>?) {
		store.createOrUpdatePatient(patient) { result in
			switch result {
			case .failure(let error):
				completion?(.failure(error))
			case .success(let patient):
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
