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
		static let outcomeUploadIimeInteval: TimeInterval = 10.0
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

	var storeOperationQueue: OperationQueue {
		.main
	}

	var cancellables: Set<AnyCancellable> = []
	var timerCancellable: AnyCancellable?
	var isSynchronizingOutcomes: Bool = false

	var patient: AlliePatient? {
		get {
			guard let userId = Keychain.userId else {
				return nil
			}
			return Keychain.readPatient(forKey: userId)
		}
		set {
			Keychain.save(patient: newValue)
			if let patient = newValue {
				Keychain.userId = patient.id
			}
		}
	}

	var vectorClock: [String: Int] {
		get {
			UserDefaults.standard.vectorClock
		}
		set {
			UserDefaults.standard.vectorClock = newValue
		}
	}

	init() {
		synchronizedStoreManager.notificationPublisher
			.sink { [weak self] notification in
				if let carePlanNotification = notification as? OCKCarePlanNotification {
					self?.processCarePlan(notification: carePlanNotification)
				} else if let patientNotification = notification as? OCKPatientNotification {
					self?.processPatient(notification: patientNotification)
				} else if let taskNotification = notification as? OCKTaskNotification {
					self?.processTask(notification: taskNotification)
				} else if let outcomeNotification = notification as? OCKOutcomeNotification {
					self?.processOutcome(notification: outcomeNotification)
				}
			}.store(in: &cancellables)
	}

	func isServerVectorClockAhead(serverClock: [String: Int]) -> Bool {
		let key = "backend"
		guard let localClockValue = vectorClock[key] else {
			return true
		}

		guard let serverClockValue = serverClock[key] else {
			return false
		}

		return serverClockValue > localClockValue
	}
}

// MARK: - CarePlanResponse

extension CareManager {
	func createOrUpdate(carePlanResponse: CarePlanResponse, forceReset: Bool = false, completion: ((Bool) -> Void)?) {
		if isServerVectorClockAhead(serverClock: carePlanResponse.vectorClock) || forceReset {
			try? resetAllContents()
		}
		let queue = DispatchQueue.global(qos: .userInitiated)
		queue.async { [weak self] in
			if let patient = carePlanResponse.patients.first {
				let thePatient = self?.syncCreateOrUpdate(patient: patient, queue: queue)
				ALog.info("patient id \(String(describing: thePatient?.id)), patient uuid = \(String(describing: thePatient?.uuid?.uuidString))")
				self?.patient = thePatient
			}

			var theCarePlan: OCKCarePlan?
			if let carePlan = carePlanResponse.carePlans.first {
				theCarePlan = self?.syncCreateOrUpdate(carePlan: carePlan, patient: self?.patient, queue: queue)
				ALog.info("CarePlan id \(String(describing: theCarePlan?.id)), carePlan uuid \(String(describing: theCarePlan?.uuid))")
			}

			let tasks = self?.syncCreateOrUpdate(tasks: carePlanResponse.tasks, carePlan: theCarePlan, queue: queue)
			completion?(!(tasks ?? []).isEmpty)
		}
	}

	@available(*, deprecated, message: "Use createOrUpdate:forceReset:completion")
	func asyncCreateOrUpdate(carePlansResponse: CarePlanResponse, completion: OCKResultClosure<Bool>?) {
		var newPatient: OCKPatient?
		if let thePatient = carePlansResponse.patients.first {
			patient = thePatient
			newPatient = OCKPatient(patient: thePatient)
		}

		let carePlans = carePlansResponse.carePlans.map { carePlan -> OCKCarePlan in
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

		let allTasks = carePlansResponse.tasks.map { task -> OCKAnyTask in
			task.ockTask
		}

		let healthKitTasks = allTasks.compactMap { task -> OCKHealthKitTask? in
			task as? OCKHealthKitTask
		}

		let careTasks = allTasks.compactMap { task -> OCKTask? in
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
	func syncCreateOrUpdate(patient: AlliePatient, queue: DispatchQueue) -> AlliePatient {
		var updatePatient = patient
		let ockPatient = OCKPatient(patient: patient)
		let dispatchGroup = DispatchGroup()
		dispatchGroup.enter()
		store.fetchPatient(withID: updatePatient.id, callbackQueue: queue) { [weak self] fetchResult in
			switch fetchResult {
			case .failure:
				self?.store.addPatient(ockPatient, callbackQueue: queue) { addResult in
					switch addResult {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
					case .success(let newPatient):
						updatePatient.uuid = newPatient.uuid
					}
					dispatchGroup.leave()
				}
			case .success(let existingPatient):
				let updated = existingPatient.merged(newPatient: ockPatient)
				self?.store.updatePatient(updated, callbackQueue: queue) { updateResult in
					switch updateResult {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
					case .success(let newPatient):
						updatePatient.uuid = newPatient.uuid
					}
					dispatchGroup.leave()
				}
			}
		}

		dispatchGroup.wait()
		return updatePatient
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
		store.createOrUpdate(patient: patient) { result in
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

extension CareManager {
	func syncCreateOrUpdate(carePlan: CarePlan, patient: AlliePatient?, queue: DispatchQueue) -> OCKCarePlan {
		var ockCarePlan = OCKCarePlan(carePlan: carePlan)
		ockCarePlan.patientUUID = patient?.uuid
		let dispatchGroup = DispatchGroup()
		dispatchGroup.enter()
		store.fetchCarePlan(withID: ockCarePlan.id, callbackQueue: queue) { [weak self] fetchResult in
			switch fetchResult {
			case .failure:
				self?.store.addCarePlan(ockCarePlan, callbackQueue: queue, completion: { addResult in
					switch addResult {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
					case .success(let newCarePlan):
						ockCarePlan = newCarePlan
					}
					dispatchGroup.leave()
				})
			case .success(let existingCarePlan):
				let merged = existingCarePlan.merged(newCarePlan: ockCarePlan)
				self?.store.updateCarePlan(merged, callbackQueue: queue, completion: { updateResult in
					switch updateResult {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
					case .success(let newCarePlan):
						ockCarePlan = newCarePlan
					}
					dispatchGroup.leave()
				})
			}
		}

		dispatchGroup.wait()
		return ockCarePlan
	}

	func syncCreateOrUpdate(carePlans: [CarePlan], patient: AlliePatient?, queue: DispatchQueue) -> [OCKCarePlan] {
		let mapped = carePlans.map { carePlan -> OCKCarePlan in
			var ockCarePlan = OCKCarePlan(carePlan: carePlan)
			ockCarePlan.patientUUID = patient?.uuid
			return ockCarePlan
		}

		var storeCarePlans: [OCKCarePlan] = []
		let dispatchGroup = DispatchGroup()
		for carePlan in mapped {
			dispatchGroup.enter()
			store.createOrUpdate(carePlan: carePlan, callbackQueue: queue) { result in
				switch result {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
				case .success(let newCarePlan):
					storeCarePlans.append(newCarePlan)
				}
				dispatchGroup.leave()
			}
		}
		dispatchGroup.wait()
		return storeCarePlans
	}
}

extension CareManager {
	func syncCreateOrUpdate(tasks: [Task], carePlan: OCKCarePlan?, queue: DispatchQueue) -> [OCKTask] {
		let mapped = tasks.map { task -> OCKTask in
			var ockTask = OCKTask(task: task)
			ockTask.carePlanUUID = carePlan?.uuid
			if ockTask.carePlanId == nil {
				ockTask.carePlanId = carePlan?.id
			}
			return ockTask
		}

		var storeTasks: [OCKTask] = []
		let dispatchGroup = DispatchGroup()
		for task in mapped {
			dispatchGroup.enter()
			store.createOrUpdate(task: task, callbackQueue: queue) { result in
				switch result {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
				case .success(let newTask):
					storeTasks.append(newTask)
				}
				dispatchGroup.leave()
			}
		}
		dispatchGroup.wait()
		return storeTasks
	}
}

extension CareManager {
	func processCarePlan(notification: OCKCarePlanNotification) {
		ALog.info("\(notification.carePlan.id) \(notification.category)")
	}

	func processPatient(notification: OCKPatientNotification) {
		ALog.info("\(notification.patient.id) \(notification.category)")
	}

	func processTask(notification: OCKTaskNotification) {
		ALog.info("\(notification.task.id) \(notification.category)")
	}

	func processOutcome(notification: OCKOutcomeNotification) {
		guard let outcome = notification.outcome as? OCKOutcome else {
			return
		}

		var taskQuery = OCKTaskQuery()
		taskQuery.uuids.append(outcome.taskUUID)
		store.fetchTasks(query: taskQuery, callbackQueue: .main) { [weak self] taskResult in
			switch taskResult {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
			case .success(let tasks):
				guard let task = tasks.first, let carePlanId = task.userInfo?["carePlanId"] else {
					return
				}

				self?.upload(outcome: outcome, task: task, carePlanId: carePlanId)
			}
		}
		ALog.info("\(notification.outcome)")
	}

	func upload(outcome: OCKOutcome, task: OCKTask, carePlanId: String) {
		let allieOutcome = Outcome(outcome: outcome, carePlanID: carePlanId, taskID: task.id)
		APIClient.client.postOutcome(outcomes: [allieOutcome])
			.sink { completion in
				switch completion {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
				case .finished:
					ALog.info("Uploaded the outcome")
				}
			} receiveValue: { response in
				ALog.info("\(response.outcomes)")
			}.store(in: &cancellables)
	}
}

extension CareManager {
	func save(outcomes: [Outcome]) -> Future<[OCKOutcome], Error> {
		Future { promise in
			DispatchQueue.global(qos: .background).async {
				let ockOutomes = outcomes.compactMap { outcome -> OCKOutcome? in
					OCKOutcome(outcome: outcome)
				}
				self.store.addOutcomes(ockOutomes, callbackQueue: .main) { result in
					switch result {
					case .success(let outcomes):
						promise(.success(outcomes))
					case .failure(let error):
						promise(.failure(error))
					}
				}
			}
		}
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
