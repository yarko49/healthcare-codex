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
import KeychainAccess
import ModelsR4
import SDWebImage
import UIKit

class CareManager: NSObject, ObservableObject {
	static let shared = CareManager(patient: nil)

	typealias BoolCompletion = (Bool) -> Void

	enum Constants {
		static let careStore = "CareStore"
		static let healthKitPassthroughStore = "HealthKitPassthroughStore"
		static let coreDataStoreType: OCKCoreDataStoreType = .onDisk(protection: .completeUnlessOpen)
		static let maximumUploadOutcomesPerCall: Int = 450
	}

	private(set) lazy var remoteSynchronizationManager: RemoteSynchronizationManager = {
		let manager = RemoteSynchronizationManager(automaticallySynchronizes: false)
		manager.delegate = self
		return manager
	}()

	private(set) lazy var store = OCKStore(name: Constants.careStore, type: Constants.coreDataStoreType, remote: remoteSynchronizationManager)
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

	private(set) lazy var synchronizedStoreManager: OCKSynchronizedStoreManager = {
		let coordinator = OCKStoreCoordinator()
		coordinator.attach(store: store)
		coordinator.attach(eventStore: healthKitStore)
		let manager = OCKSynchronizedStoreManager(wrapping: coordinator)
		return manager
	}()

	var cancellables: Set<AnyCancellable> = []
	var uploadQueue: DispatchQueue = {
		let bundleIdentifier = Bundle.main.bundleIdentifier!
		let queue = DispatchQueue(label: bundleIdentifier + ".UploadQueue", qos: .background, attributes: [], autoreleaseFrequency: .inherit, target: nil)
		return queue
	}()

	private var uploadOperationQueues: [String: OperationQueue] = [:]
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
	func process(carePlanResponse: CHCarePlanResponse, forceReset: Bool = false, completion: BoolCompletion?) {
		let queue = DispatchQueue.global(qos: .userInitiated)
		var result: Bool = true
		queue.async { [weak self] in
			if let patient = carePlanResponse.patients.first {
				let thePatient = self?.syncProcess(patient: patient, queue: queue)
				ALog.debug("patient id \(String(describing: thePatient?.id)), patient uuid = \(String(describing: thePatient?.uuid?.uuidString))")
				self?.patient = thePatient
				result = thePatient != nil
			}

			var theCarePlan: OCKCarePlan?
			if let carePlan = carePlanResponse.carePlans.first, result {
				theCarePlan = self?.syncProcess(carePlan: carePlan, patient: self?.patient, queue: queue)
				ALog.debug("CarePlan id \(String(describing: theCarePlan?.id)), carePlan uuid \(String(describing: theCarePlan?.uuid))")
				result = theCarePlan != nil
			}

			let tasks = self?.syncProcess(tasks: carePlanResponse.tasks, carePlan: theCarePlan, queue: queue)
			ALog.debug("Regular tasks saved = \(String(describing: tasks?.0.count)), HealthKitTasks saved \(String(describing: tasks?.1.count))")
			if !carePlanResponse.outcomes.isEmpty, result {
				let outcomes = self?.syncCreateOrUpdate(outcomes: carePlanResponse.outcomes, queue: queue)
				result = outcomes != nil
				ALog.debug("Number out outcomes saved \(String(describing: outcomes?.count))")
			}
			self?.synchronizeHealthKitOutcomes()
			completion?(result)
		}
	}

	class func postPatient(patient: CHPatient) -> Future<CHCarePlanResponse, Error> {
		APIClient.shared.post(patient: patient)
	}

	class func register(organization: CHOrganization) -> Future<Bool, Never> {
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
				healthKitStore.addOrUpdate(healthKitTask: healthKitTask, callbackQueue: queue) { result in
					switch result {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
					case .success(let newTask):
						healthKitTasks.append(newTask)
					}
					dispatchGroup.leave()
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

	func delete(taskId: String) -> Future<[OCKAnyTask], Error> {
		Future { promise in
			let query = OCKTaskQuery(id: taskId)
			self.store.fetchAnyTasks(query: query, callbackQueue: .main) { fetchResult in
				switch fetchResult {
				case .failure(let error):
					promise(.failure(error))
				case .success(let tasks):
					self.store.deleteAnyTasks(tasks, callbackQueue: .main) { deleteResult in
						switch deleteResult {
						case .failure(let error):
							promise(.failure(error))
						case .success(let tasks):
							promise(.success(tasks))
						}
					}
				}
			}
		}
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
