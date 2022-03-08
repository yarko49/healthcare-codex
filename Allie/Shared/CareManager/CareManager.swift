//
//  CareManager.swift
//  Allie
//
//  Created by Waqar Malik on 11/23/20.
//

import CareKit
import CareKitStore
import CareModel
import CodexFoundation
import CodexModel
import Combine
import CoreData
import HealthKit
import KeychainAccess
import UIKit

class CareManager: NSObject, ObservableObject {
	@Injected(\.careManager) static var shared: CareManager // Hack for few things
	enum Constants {
		static let careStore = "CareStore"
		static let healthKitPassthroughStore = "HealthKitPassthroughStore"
		static let coreDataStoreType: OCKCoreDataStoreType = .onDisk(protection: .completeUntilFirstUserAuthentication)
		static let maximumUploadOutcomesPerCall: Int = 450
		static let deleteDelayTimeIntervalSeconds: Int = 2
	}

	private(set) lazy var store = OCKStore(name: Constants.careStore, securityApplicationGroupIdentifier: nil, type: Constants.coreDataStoreType, remote: nil)
	private(set) lazy var healthKitStore: OCKHealthKitPassthroughStore = {
		let healthKitStore = OCKHealthKitPassthroughStore(store: store)
		healthKitStore.samplesToOutcomesValueMapper = { samples, task in
			var outcomeValues: [OCKOutcomeValue] = []
			samples.forEach { sample in
				let values = sample.outcomeValues(task: task)
				outcomeValues.append(contentsOf: values)
			}
			return outcomeValues
		}
		return healthKitStore
	}()

	private(set) lazy var synchronizedStoreManager: OCKSynchronizedStoreManager = {
		let coordinator = OCKStoreCoordinator()
		coordinator.attach(eventStore: healthKitStore)
		coordinator.attach(store: store)
		let manager = OCKSynchronizedStoreManager(wrapping: coordinator)
		return manager
	}()

	var cancellables: Set<AnyCancellable> = []
	var uploadQueue: DispatchQueue = {
		let bundleIdentifier = Bundle.main.bundleIdentifier!
		let queue = DispatchQueue(label: bundleIdentifier + ".UploadQueue", qos: .background, attributes: [], autoreleaseFrequency: .inherit, target: nil)
		return queue
	}()

	@Injected(\.networkAPI) var networkAPI: AllieAPI
	@Injected(\.healthKitManager) var healthKitManager: HealthKitManager
	@Injected(\.keychain) var keychain: Keychain
	@Injected(\.remoteConfig) var remoteConfig: RemoteConfigManager

	private var uploadOperationQueues: [String: OperationQueue] = [:]
	var hkInflightUploadIdentifiers = InflightIdentifers<HKQuantityTypeIdentifier>()
	var inflightUploadIdentifiers = InflightIdentifers<String>()
	var outcomeUploadInProgress: Bool = false

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
			keychain.patient
		}
		set {
			keychain.patient = newValue
			startUploadOutcomesTimer(timeInterval: remoteConfig.outcomesUploadTimeInterval)
			AppDelegate.registerServices(patient: newValue)
		}
	}

	override required init() {
		super.init()
		commonInit()
	}

	convenience init(patient: CHPatient?) {
		self.init()
		if let patient = patient {
			self.patient = patient
		}
	}

	private func commonInit() {
		registerForNotifications()
		registerForConfighanges()

		do {
			let carePlanResponse = try readCarePlan()
			self.carePlanResponse = carePlanResponse
			tasks = carePlanResponse.tasks.reduce([:]) { partialResult, task in
				var result = partialResult
				result[task.id] = task
				return result
			}
			carePlan = carePlanResponse.carePlans.active.first
		} catch {
			ALog.error("CarePlan Missing \(error.localizedDescription)")
		}
	}

	func registerForConfighanges() {
		remoteConfig.$outcomesUploadTimeInterval
			.sink { [weak self] timeInterval in
				if timeInterval > 0 {
					self?.cancelUploadOutcomesTimer()
					self?.startUploadOutcomesTimer(timeInterval: timeInterval)
				}
			}.store(in: &cancellables)
	}

	func registerForNotifications() {
		NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
			.sink { [weak self] _ in
				self?.startUploadOutcomesTimer(timeInterval: self?.remoteConfig.outcomesUploadTimeInterval ?? 5)
				ALog.trace("Did Start the Outcomes Timer")
			}.store(in: &cancellables)

		NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
			.sink { [weak self] _ in
				self?.cancelUploadOutcomesTimer()
				ALog.trace("Did Cancel the Outcomes Timer")
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
				self?.synchronizeOutcomes()
			})
	}

	func cancelUploadOutcomesTimer() {
		uploadOutcomesTimer?.cancel()
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

	private(set) var carePlanResponse: CHCarePlanResponse?
	private(set) var carePlan: CHCarePlan?
	private(set) var tasks: [String: CHTask] = [:]

	private(set) lazy var dbStore: CoreDataManager = .init(modelName: "HealthStore")

	var planProcesstask: Task<Void, Never>?
	let processingQueue: DispatchQueue = {
		let bundleIdentifier = Bundle.main.bundleIdentifier!
		let queue = DispatchQueue(label: bundleIdentifier + ".CarePlan", qos: .userInitiated, attributes: [], autoreleaseFrequency: .inherit, target: nil)
		return queue
	}()
}

// MARK: - CarePlanResponse

extension CareManager {
	func process(carePlanResponse: CHCarePlanResponse, forceReset: Bool = false, completion: AllieResultCompletion<CHCarePlanResponse>?) {
		// If the care plan response is empty we need to reset every thing
		if carePlanResponse.carePlans.isEmpty || carePlanResponse.tasks.isEmpty {
			try? resetAllContents()
		}

		// if we have a care plan check if the vector clock is ahead then upate, otherwise we are good
		if let existingCare = self.carePlanResponse, existingCare.vectorClock <= carePlanResponse.vectorClock {
			completion?(.success(carePlanResponse))
			return
		}
		planProcesstask?.cancel()
		planProcesstask = Task.detached(priority: .userInitiated, operation: { [weak self] in
			guard let strongSelf = self else {
				return
			}
			ALog.info("isMainThread \(Thread.isMainThread)")
			do {
				let response = try await strongSelf.process(carePlanResponse: carePlanResponse, forceReset: forceReset)
				completion?(.success(response))
			} catch {
				completion?(.failure(error))
			}
		})
	}

	func process(carePlanResponse: CHCarePlanResponse, forceReset: Bool = false) async throws -> CHCarePlanResponse {
		var updateCarePlanResponse = CHCarePlanResponse()
		tasks = carePlanResponse.tasks.reduce([:]) { partialResult, task in
			var result = partialResult
			result[task.id] = task
			return result
		}

		let existingCarePlanResponse = self.carePlanResponse
		do {
			try await writeStoreCarePlan()
		} catch {
			ALog.error("Unable to write careplan", error: error)
		}
		patient = carePlanResponse.patients.active.first
		carePlan = carePlanResponse.carePlans.active.first
		try save(carePlanResponse: carePlanResponse)
		self.carePlanResponse = carePlanResponse
		// We do not store patient object in CareKitStore
		do {
			try await deleteAllPatients()
		} catch {
			ALog.error("Unable to delete patients", error: error)
		}
		// We do not store any careplans in CareKitStore

		do {
			try await deleteAllCarePlans()
		} catch {
			ALog.error("Unable to delete carePlans", error: error)
		}

		let carePlans = carePlanResponse.carePlans
		let activeCarePlan = carePlans.active.first
		let taskIds = carePlanResponse.tasks.map { task in
			task.id
		}
		try await deleteTasks(exclude: Set(taskIds), carePlans: [])
		try await deleteHealthKitTasks(exclude: Set(taskIds), carePlans: [])
		let toProcess = carePlanResponse.tasks(forCarePlanId: activeCarePlan?.id ?? "")
		if !toProcess.isEmpty {
			let existingTasks = existingCarePlanResponse?.tasks ?? []
			let shouldUpdateTasks = existingTasks != toProcess

			if shouldUpdateTasks {
				do {
					let existingTasksById: [String: CHTask] = existingTasks.reduce([:]) { partialResult, task in
						var result = partialResult
						result[task.id] = task
						return result
					}

					let processedTasks = try await process(tasks: toProcess, carePlan: activeCarePlan, existingTasks: existingTasksById)
					ALog.info("Tasks saved = \(String(describing: processedTasks.count))")
					updateCarePlanResponse.tasks.append(contentsOf: processedTasks)
				} catch {
					ALog.error("Error Procesing tasks", error: error)
				}
			}
		}
		let toDelete = carePlanResponse.tasks.deleted
		if !toDelete.isEmpty {
			do {
				let processedTasks = try await process(tasks: toProcess, carePlan: activeCarePlan, existingTasks: [:])
				updateCarePlanResponse.tasks.append(contentsOf: processedTasks)
				ALog.info("Tasks deleted = \(String(describing: processedTasks.count))")
			} catch {
				ALog.error("Error Procesing tasks", error: error)
			}
		}

		try save(carePlanResponse: updateCarePlanResponse)
		self.carePlanResponse = updateCarePlanResponse
		return updateCarePlanResponse
	}

	func register(organization: CMOrganization) -> AnyPublisher<Bool, Never> {
		networkAPI.registerOrganization(organization: organization)
	}

	func synchronizeOutcomes() {
		synchronizeHealthKitOutcomes()
		synchronizeCareKitOutcomes()
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

// MARK: - Reset

extension CareManager {
	func resetAllContents() throws {
		try store.reset()
		try healthKitStore.reset()
		try resetCarePlan()
		dbStore.resetAllRecords(in: "MappedOutcome")
	}
}

// MARK: - OCKRemoteSynchronizationDelegate

extension CareManager: OCKRemoteSynchronizationDelegate {
	public func didRequestSynchronization(_ remote: OCKRemoteSynchronizable) {
		ALog.trace("Did Request Synchronization")
	}

	public func remote(_ remote: OCKRemoteSynchronizable, didUpdateProgress progress: Double) {
		ALog.trace("Did Update Progress")
	}
}

extension CareManager: OCKResetDelegate {
	func storeDidReset(_ store: OCKAnyResettableStore) {
		ALog.trace("Store \(store) did reset")
	}
}

extension CareManager {
	func writeStoreCarePlan() async throws {
		let fileManager = FileManager()
		guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
			throw AllieError.forbidden("Missing directory")
		}
		let ockTask = documentsDirectory.appendingPathComponent("CareKitStoreOCKTasks.json")
		let query = OCKTaskQuery(for: Date())
		let tasks = try await store.fetchAnyTasks(query: query)
		let ockTasks = tasks.compactMap { anyTask in
			anyTask as? OCKTask
		}
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601WithFractionalSeconds
		let ockData = try encoder.encode(ockTasks)
		try ockData.write(to: ockTask, options: .atomic)
		let healthKitTasks = tasks.compactMap { anyTask in
			anyTask as? OCKHealthKitTask
		}

		let hkTask = documentsDirectory.appendingPathComponent("CareKitStoreHKTasks.json")
		let hkData = try encoder.encode(healthKitTasks)
		try hkData.write(to: hkTask, options: .atomic)
	}
}
