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

class CareManager: NSObject, ObservableObject {
	typealias BoolCompletion = (Bool) -> Void

	enum Constants {
		static let outcomeUploadIimeInteval: TimeInterval = 10.0 * 60
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

	var cancellables: Set<AnyCancellable> = []
	var isSynchronizingOutcomes: Bool = false
	var outcomeUploaders: Set<DataUploadManager<CarePlanResponse>> = []

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

	override init() {
		super.init()
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
		let queue = DispatchQueue.global(qos: .userInitiated)
		var result: Bool = true
		queue.async { [weak self] in
			if let patient = carePlanResponse.patients.first {
				let thePatient = self?.syncCreateOrUpdate(patient: patient, queue: queue)
				ALog.info("patient id \(String(describing: thePatient?.id)), patient uuid = \(String(describing: thePatient?.uuid?.uuidString))")
				self?.patient = thePatient
				result = thePatient != nil
			}

			var theCarePlan: OCKCarePlan?
			if let carePlan = carePlanResponse.carePlans.first, result {
				theCarePlan = self?.syncCreateOrUpdate(carePlan: carePlan, patient: self?.patient, queue: queue)
				ALog.info("CarePlan id \(String(describing: theCarePlan?.id)), carePlan uuid \(String(describing: theCarePlan?.uuid))")
				result = theCarePlan != nil
			}

			let tasks = self?.syncCreateOrUpdate(tasks: carePlanResponse.tasks, carePlan: theCarePlan, queue: queue)
			ALog.info("Regular tasks saved = \(String(describing: tasks?.0.count)), HealthKitTasks saved \(String(describing: tasks?.1.count))")
			if !carePlanResponse.outcomes.isEmpty, result {
				let outcomes = self?.syncCreateOrUpdate(outcomes: carePlanResponse.outcomes, queue: queue)
				result = outcomes != nil
				ALog.info("Number out outcomes saved \(String(describing: outcomes?.count))")
			}
			completion?(result)
		}
	}

	class func getCarePlan(completion: OCKResultClosure<CarePlanResponse>?) {
		APIClient.shared.getCarePlan(option: .outcomes) { result in
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
		APIClient.shared.post(patient: patient)
	}

	class func register(provider: String) -> Future<Bool, Never> {
		APIClient.shared.regiterProvider(identifier: provider)
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
}

// MARK: - CarePlans

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

// MARK: - Tasks

extension CareManager {
	func syncCreateOrUpdate(tasks: [Task], carePlan: OCKCarePlan?, queue: DispatchQueue) -> ([OCKTask], [OCKHealthKitTask]) {
		let mapped = tasks.map { task -> OCKAnyTask in
			if task.healthKitLinkage != nil {
				var healKitTask = OCKHealthKitTask(task: task)
				healKitTask.carePlanUUID = carePlan?.uuid
				if healKitTask.carePlanId == nil {
					healKitTask.carePlanId = carePlan?.id
				}
				return healKitTask
			} else {
				var ockTask = OCKTask(task: task)
				ockTask.carePlanUUID = carePlan?.uuid
				if ockTask.carePlanId == nil {
					ockTask.carePlanId = carePlan?.id
				}
				return ockTask
			}
		}

		var healthKitTasks: [OCKHealthKitTask] = []
		var storeTasks: [OCKTask] = []
		let dispatchGroup = DispatchGroup()
		for task in mapped {
			if let healthKitTask = task as? OCKHealthKitTask {
				dispatchGroup.enter()
				healthKitStore.createOrUpdate(healthKitTask: healthKitTask, callbackQueue: queue) { result in
					switch result {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
					case .success(let newTask):
						healthKitTasks.append(newTask)
					}
					dispatchGroup.leave()
				}
			} else if let ockTask = task as? OCKTask {
				dispatchGroup.enter()
				store.createOrUpdate(task: ockTask, callbackQueue: queue) { result in
					switch result {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
					case .success(let newTask):
						storeTasks.append(newTask)
					}
					dispatchGroup.leave()
				}
			}
		}
		dispatchGroup.wait()
		return (storeTasks, healthKitTasks)
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
}

extension CareManager {
	func syncCreateOrUpdate(outcome: Outcome, queue: DispatchQueue) -> OCKOutcome {
		var ockOutcome = OCKOutcome(outcome: outcome)
		let dispatchGroup = DispatchGroup()
		var query = OCKOutcomeQuery()
		if let remoteId = outcome.remoteID {
			query.remoteIDs = [remoteId]
		}

		dispatchGroup.enter()
		store.fetchOutcome(query: query, callbackQueue: queue) { [weak self] result in
			switch result {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
				self?.store.addOutcome(ockOutcome, callbackQueue: queue, completion: { addResult in
					switch addResult {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
					case .success(let newOutcome):
						ockOutcome = newOutcome
					}
					dispatchGroup.leave()
				})
			case .success(let existingOutcome):
				let merged = existingOutcome.merged(newOutcome: ockOutcome)
				self?.store.updateOutcome(merged, callbackQueue: queue, completion: { updateResult in
					switch updateResult {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
					case .success(let newOutcome):
						ockOutcome = newOutcome
					}
					dispatchGroup.leave()
				})
			}
		}

		dispatchGroup.wait()
		return ockOutcome
	}

	func syncCreateOrUpdate(outcomes: [Outcome], queue: DispatchQueue) -> [OCKOutcome] {
		let mapped = outcomes.map { outcome -> OCKOutcome in
			OCKOutcome(outcome: outcome)
		}

		var storeOutcomes: [OCKOutcome] = []
		let dispatchGroup = DispatchGroup()
		for outcome in mapped {
			dispatchGroup.enter()
			store.createOrUpdate(outcome: outcome, callbackQueue: queue) { result in
				switch result {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
				case .success(let newOutcome):
					storeOutcomes.append(newOutcome)
				}
				dispatchGroup.leave()
			}
		}
		dispatchGroup.wait()
		return storeOutcomes
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
		APIClient.shared.post(outcomes: [allieOutcome])
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

	func getOutcomes() {
		APIClient.shared.getOutcomes()
			.sink { completionResult in
				switch completionResult {
				case .finished:
					break
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
				}
			} receiveValue: { response in
				ALog.info("Number of carePlans = \(response.carePlans.count)")
				ALog.info("Number of patients = \(response.patients.count)")
				ALog.info("Number of tasks = \(response.tasks.count)")
				ALog.info("Number of outcomes = \(response.outcomes.count)")
			}.store(in: &cancellables)
	}

	func save(outcomes: [Outcome]) -> Future<[OCKOutcome], Error> {
		Future { promise in
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
