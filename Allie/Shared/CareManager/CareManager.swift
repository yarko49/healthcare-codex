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
import HealthKit
import KeychainAccess
import ModelsR4
import SDWebImage
import UIKit
import WatchConnectivity

class CareManager: NSObject, ObservableObject {
	static let shared = CareManager(patient: nil)

	enum Constants {
		static let careStore = "CareStore"
		static let healthKitPassthroughStore = "HealthKitPassthroughStore"
		static let coreDataStoreType: OCKCoreDataStoreType = .onDisk(protection: .completeUntilFirstUserAuthentication)
		static let maximumUploadOutcomesPerCall: Int = 450
		static let deleteDelayTimeIntervalSeconds: Int = 2
	}

	private(set) lazy var peer = OCKWatchConnectivityPeer()
	private(set) lazy var store = OCKStore(name: Constants.careStore, securityApplicationGroupIdentifier: nil, type: Constants.coreDataStoreType, remote: nil)
	private(set) lazy var healthKitStore: OCKHealthKitPassthroughStore = {
		let healthKitStore = OCKHealthKitPassthroughStore(store: store)
		healthKitStore.samplesToOutcomesValueMapper = { samples, task in
			var outcomes: [OCKOutcomeValue] = []
			samples.forEach { sample in
				let values = sample.outcomeValues(task: task)
				outcomes.append(contentsOf: values)
			}
			return outcomes
		}
		return healthKitStore
	}()

	private(set) lazy var synchronizedStoreManager: CHSynchronizedStoreManager = {
		let coordinator = OCKStoreCoordinator()
		coordinator.attach(eventStore: healthKitStore)
		coordinator.attach(store: store)
		let manager = CHSynchronizedStoreManager(wrapping: coordinator)
		return manager
	}()

	var cancellables: Set<AnyCancellable> = []
	var uploadQueue: DispatchQueue = {
		let bundleIdentifier = Bundle.main.bundleIdentifier!
		let queue = DispatchQueue(label: bundleIdentifier + ".UploadQueue", qos: .background, attributes: [], autoreleaseFrequency: .inherit, target: nil)
		return queue
	}()

	private var uploadOperationQueues: [String: OperationQueue] = [:]
	var inflightUploadIdentifiers = InflightIdentifers()
	subscript(uploadOperationQueue identifier: String) -> OperationQueue {
		get {
			guard let queue = uploadOperationQueues[identifier] else {
				let queue = OperationQueue()
				queue.name = Bundle(for: CareManager.self).bundleIdentifier! + identifier
				queue.qualityOfService = .userInitiated
				queue.maxConcurrentOperationCount = 1
				uploadOperationQueues[identifier] = queue
				return queue
			}
			return queue
		}
		set {
			let existingQueue = uploadOperationQueues[identifier]
			existingQueue?.cancelAllOperations()
			uploadOperationQueues[identifier] = newValue
		}
	}

	var patient: CHPatient? {
		get {
			Keychain.patient
		}
		set {
			Keychain.patient = newValue
			startUploadOutcomesTimer(timeInterval: RemoteConfigManager.shared.outcomesUploadTimeInterval)
			AppDelegate.registerServices(patient: newValue)
		}
	}

	var vectorClock: UInt64 {
		get {
			UserDefaults.standard.vectorClock
		}
		set {
			UserDefaults.standard.vectorClock = newValue
		}
	}

	@available(*, unavailable)
	override required init() {
		fatalError("init() has not been implemented")
	}

	// Hack so we cannot instantiate more than one
	private init(patient: CHPatient?) {
		super.init()
		registerForNotifications()
		registerForConfighanges()
	}

	func registerForConfighanges() {
		let configManager = RemoteConfigManager.shared
		configManager.$outcomesUploadTimeInterval
			.sink { [weak self] timeInterval in
				if timeInterval > 0 {
					self?.cancelUploadOutcomesTimer()
					self?.startUploadOutcomesTimer(timeInterval: timeInterval)
				}
			}.store(in: &cancellables)
	}

	func registerForNotifications() {
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

		NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
			.sink { [weak self] _ in
				self?.startUploadOutcomesTimer(timeInterval: RemoteConfigManager.shared.outcomesUploadTimeInterval)
				ALog.info("Did Start the Outcomes Timer")
			}.store(in: &cancellables)

		NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
			.sink { [weak self] _ in
				self?.cancelUploadOutcomesTimer()
				ALog.info("Did Cancel the Outcomes Timer")
			}.store(in: &cancellables)
	}

	private var uploadOutcomesTimer: AnyCancellable?
	func startUploadOutcomesTimer(timeInterval: TimeInterval) {
		guard patient != nil else {
			return
		}
		cancelUploadOutcomesTimer()
		uploadOutcomesTimer = Timer.publish(every: timeInterval, on: .main, in: .common)
			.autoconnect()
			.sink(receiveValue: { [weak self] _ in
				ALog.trace("Upload timer fired")
				self?.synchronizeHealthKitOutcomes()
			})
	}

	func cancelUploadOutcomesTimer() {
		uploadOutcomesTimer?.cancel()
	}

	func isServerVectorClockAhead(serverClock: UInt64) -> Bool {
		serverClock > vectorClock
	}

	func reset() {
		cancellables.forEach { cancellable in
			cancellable.cancel()
		}
		uploadOperationQueues.forEach { queue in
			queue.value.cancelAllOperations()
		}
		try? resetAllContents()
	}
}

// MARK: - CarePlanResponse

extension CareManager {
	func process(carePlanResponse: CHCarePlanResponse, forceReset: Bool = false, completion: AllieResultCompletion<[CHTask]>?) {
		let queue = DispatchQueue.global(qos: .userInitiated)
		var result: OCKStoreError?
		queue.async { [weak self] in
			if let patient = carePlanResponse.patients.first {
				let thePatient = self?.syncProcess(patient: patient, queue: queue)
				ALog.debug("patient id \(String(describing: thePatient?.id)), patient uuid = \(String(describing: thePatient?.uuid?.uuidString))")
				self?.patient = thePatient
				if thePatient == nil {
					result = OCKStoreError.updateFailed(reason: "Unable to update Patient")
				}
			}

			var theCarePlan: OCKCarePlan?
			if let carePlan = carePlanResponse.carePlans.first, result == nil {
				theCarePlan = self?.syncProcess(carePlan: carePlan, patient: self?.patient, queue: queue)
				ALog.debug("CarePlan id \(String(describing: theCarePlan?.id)), carePlan uuid \(String(describing: theCarePlan?.uuid))")
				if theCarePlan == nil {
					result = OCKStoreError.updateFailed(reason: "Unable to ")
				}
			}

			let toDelete = carePlanResponse.tasks.filter { task in
				task.shouldDelete
			}

			let toProcess = carePlanResponse.tasks
			if result == nil {
				let processedTasks = self?.syncProcess(tasks: toProcess, carePlan: theCarePlan, queue: queue) ?? ([], [])
				ALog.debug("Regular tasks saved = \(String(describing: processedTasks.0.count)), HealthKitTasks saved \(String(describing: processedTasks.1.count))")

				if (processedTasks.0.count + processedTasks.1.count) != toProcess.count {
					result = OCKStoreError.updateFailed(reason: "Error updating tasks")
				}
			}

			if !carePlanResponse.outcomes.isEmpty, result == nil {
				let outcomes = self?.syncCreateOrUpdate(outcomes: carePlanResponse.outcomes, queue: queue)
				if outcomes == nil {
					result = OCKStoreError.updateFailed(reason: "Outcomes update failed")
				}
				ALog.debug("Number out outcomes saved \(String(describing: outcomes?.count))")
			}
			self?.synchronizeHealthKitOutcomes()

			if let error = result {
				completion?(.failure(error))
			} else {
				completion?(.success(toDelete))
			}
		}
	}

	class func postPatient(patient: CHPatient) -> AnyPublisher<CHCarePlanResponse, Error> {
		APIClient.shared.post(patient: patient)
	}

	class func register(organization: CHOrganization) -> AnyPublisher<Bool, Never> {
		APIClient.shared.registerOrganization(organization: organization)
	}
}

// MARK: - Patients

extension CareManager {
	func syncProcess(patient: CHPatient, queue: DispatchQueue) -> CHPatient {
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

	func process(patient: OCKPatient, completion: OCKResultClosure<OCKPatient>?) {
		store.process(patient: patient, callbackQueue: .main) { result in
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
	func syncProcess(carePlan: CHCarePlan, patient: CHPatient?, queue: DispatchQueue) -> OCKCarePlan {
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

	func syncProcess(carePlans: [CHCarePlan], patient: CHPatient?, queue: DispatchQueue) -> [OCKCarePlan] {
		let mapped = carePlans.map { carePlan -> OCKCarePlan in
			var ockCarePlan = OCKCarePlan(carePlan: carePlan)
			ockCarePlan.patientUUID = patient?.uuid
			return ockCarePlan
		}

		var storeCarePlans: [OCKCarePlan] = []
		let dispatchGroup = DispatchGroup()
		for carePlan in mapped {
			dispatchGroup.enter()
			store.process(carePlan: carePlan, callbackQueue: queue) { result in
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
	func syncProcess(tasks: [CHTask], carePlan: OCKCarePlan?, queue: DispatchQueue) -> ([OCKTask], [OCKHealthKitTask]) {
		let mappedTasks = tasks.map { task -> (CHTask, OCKAnyTask) in
			if task.healthKitLinkage != nil {
				var healKitTask = OCKHealthKitTask(task: task)
				healKitTask.carePlanUUID = carePlan?.uuid
				if healKitTask.carePlanId == nil {
					healKitTask.carePlanId = carePlan?.id
				}
				return (task, healKitTask)
			} else {
				var ockTask = OCKTask(task: task)
				ockTask.carePlanUUID = carePlan?.uuid
				if ockTask.carePlanId == nil {
					ockTask.carePlanId = carePlan?.id
				}
				return (task, ockTask)
			}
		}

		var healthKitTasks: [OCKHealthKitTask] = []
		var storeTasks: [OCKTask] = []
		let dispatchGroup = DispatchGroup()
		for (task, anyTask) in mappedTasks {
			if let healthKitTask = anyTask as? OCKHealthKitTask {
				dispatchGroup.enter()
				if task.shouldDelete {
					healthKitStore.deleteTask(healthKitTask, callbackQueue: queue) { result in
						switch result {
						case .failure(let error):
							ALog.error("\(error.localizedDescription)")
						case .success(let newTask):
							healthKitTasks.append(newTask)
						}
						dispatchGroup.leave()
					}
				} else {
					healthKitStore.addOrUpdate(healthKitTask: healthKitTask, callbackQueue: queue) { result in
						switch result {
						case .failure(let error):
							ALog.error("\(error.localizedDescription)")
						case .success(let newTask):
							healthKitTasks.append(newTask)
						}
						dispatchGroup.leave()
					}
				}
			} else if let ockTask = anyTask as? OCKTask {
				dispatchGroup.enter()
				store.process(task: ockTask, callbackQueue: queue) { result in
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
	func syncCreateOrUpdate(outcome: CHOutcome, queue: DispatchQueue) -> OCKOutcome {
		var ockOutcome = OCKOutcome(outcome: outcome)
		var query = OCKOutcomeQuery()
		if let remoteId = outcome.remoteID {
			query.remoteIDs = [remoteId]
		}

		let dispatchGroup = DispatchGroup()
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

	func syncCreateOrUpdate(outcomes: [CHOutcome], queue: DispatchQueue) -> [OCKOutcome] {
		let mapped = outcomes.map { outcome -> OCKOutcome in
			OCKOutcome(outcome: outcome)
		}

		var storeOutcomes: [OCKOutcome] = []
		let dispatchGroup = DispatchGroup()
		for outcome in mapped {
			dispatchGroup.enter()
			store.process(outcome: outcome, callbackQueue: queue) { result in
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
		guard var outcome = notification.outcome as? OCKOutcome else {
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

	func upload(outcomes: [OCKAnyOutcome]) {
		guard !outcomes.isEmpty else {
			return
		}
		let group = DispatchGroup()
		var chOutcomes: [CHOutcome] = []
		for outcome in outcomes {
			let hkOutcome = outcome as? OCKHealthKitOutcome
			let ockOutcome = outcome as? OCKOutcome
			guard let taskUUID = hkOutcome?.taskUUID ?? ockOutcome?.taskUUID else {
				continue
			}
			group.enter()
			var taskQuery = OCKTaskQuery()
			taskQuery.uuids.append(taskUUID)
			store.fetchTasks(query: taskQuery, callbackQueue: .main) { taskResult in
				switch taskResult {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
				case .success(let tasks):
					guard let task = tasks.first, let carePlanId = task.userInfo?["carePlanId"] else {
						return
					}
					if let theOutcome = hkOutcome {
						let chOutcome = CHOutcome(hkOutcome: theOutcome, carePlanID: carePlanId, taskID: task.id)
						chOutcomes.append(chOutcome)
					} else if let theOutcome = ockOutcome {
						let chOutcome = CHOutcome(outcome: theOutcome, carePlanID: carePlanId, taskID: task.id)
						chOutcomes.append(chOutcome)
					}
				}
				group.leave()
			}

			group.notify(queue: .main) { [weak self] in
				self?.upload(outcomes: outcomes)
			}
		}
	}

	func upload(outcomes: [CHOutcome]) {
		guard !outcomes.isEmpty else {
			return
		}

		APIClient.shared.post(outcomes: outcomes)
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

	func upload(outcome: OCKOutcome, task: OCKTask, carePlanId: String) {
		let allieOutcome = CHOutcome(outcome: outcome, carePlanID: carePlanId, taskID: task.id)
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

	func save(outcomes: [CHOutcome]) -> Future<[OCKOutcome], Error> {
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

	func deleteOutcomes(task: CHTask, completion: @escaping AllieResultCompletion<[OCKOutcome]>) {
		let dateInterval = DateInterval(start: task.effectiveDate, end: Date.distantFuture)
		var outcomeQuery = OCKOutcomeQuery(dateInterval: dateInterval)
		outcomeQuery.taskIDs = [task.id]
		store.fetchOutcomes(query: outcomeQuery) { [weak self] fetchResult in
			switch fetchResult {
			case .failure(let error):
				ALog.error("No outcoms found for task id \(task.id)", error: error)
				completion(.failure(error))
			case .success(let outcomes):
				self?.store.deleteOutcomes(outcomes) { deleteResult in
					switch deleteResult {
					case .failure(let error):
						ALog.error("Unable to delete outcomes for task \(task.id)", error: error)
						completion(.failure(error))
					case .success(let deletedOutcomes):
						completion(.success(deletedOutcomes))
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
