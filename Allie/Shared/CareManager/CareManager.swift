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

	var carePlanResponse: CHCarePlanResponse?
	var activeCarePlan: CHCarePlan?
	var tasks: [String: CHTask] = [:] // Key == careplanId + taskId
	var carePlans: [String: CHCarePlan] = [:]

	private(set) lazy var dbStore: CoreDataManager = .init(modelName: "HealthStore")

	var planProcessTask: Task<Void, Never>?
	let processingQueue: DispatchQueue = {
		let bundleIdentifier = Bundle.main.bundleIdentifier!
		let queue = DispatchQueue(label: bundleIdentifier + ".CarePlan", qos: .userInitiated, attributes: [], autoreleaseFrequency: .inherit, target: nil)
		return queue
	}()
}

// MARK: - CarePlanResponse

extension CareManager {
	func process(newCarePlanResponse: CHCarePlanResponse, forceReset: Bool = false, completion: AllieResultCompletion<CHCarePlanResponse>?) {
		planProcessTask?.cancel()
		planProcessTask = Task.detached(priority: .userInitiated, operation: { [weak self] in
			guard let strongSelf = self else {
				return
			}
			do {
				let response = try await strongSelf.process(newCarePlanResponse: newCarePlanResponse, forceReset: forceReset)
				completion?(.success(response))
			} catch {
				completion?(.failure(error))
			}
		})
	}

	func process(newCarePlanResponse response: CHCarePlanResponse, forceReset: Bool = false) async throws -> CHCarePlanResponse {
		// If the care plan response is empty we need to reset every thing
		if response.carePlans.isEmpty || response.tasks.isEmpty {
			try? resetAllContents()
			return response
		}

		// if we have a care plan check if the vector clock is ahead then upate, otherwise we are good
		if let existingCare = carePlanResponse, existingCare.vectorClock <= response.vectorClock {
			return response
		}

		let newCarePlanResponse = response
		let existingCarePlanResponse = carePlanResponse
		process(carePlanResponse: newCarePlanResponse)
		try saveCarePlan()
		if let activeCarePlanId = activeCarePlan?.id {
			try await deleteTasks(exclude: [], carePlans: [activeCarePlanId])
		}

		let toProcess = Array(tasks.values)
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
				} catch {
					ALog.error("Error Procesing tasks", error: error)
				}
			}
		}

		var toDelete = newCarePlanResponse.tasks.deleted
		let hidden = newCarePlanResponse.tasks.filter { task in
			task.isHidden
		}
		toDelete.append(contentsOf: hidden)
		if !toDelete.isEmpty {
			do {
				try await delete(tasks: toDelete)
				ALog.info("Tasks deleted = \(toDelete.count))")
			} catch {
				ALog.error("Error Procesing tasks", error: error)
			}
		}

		return newCarePlanResponse
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
