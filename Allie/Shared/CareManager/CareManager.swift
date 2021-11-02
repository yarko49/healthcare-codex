//
//  CareManager.swift
//  Allie
//
//  Created by Waqar Malik on 11/23/20.
//

import CareKit
import CareKitStore
import Combine
import CoreData
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

	@Injected(\.networkAPI) var networkAPI: AllieAPI
	@Injected(\.healthKitManager) var healthKitManager: HealthKitManager
	@Injected(\.keychain) var keychain: Keychain
	@Injected(\.remoteConfig) var remoteConfig: RemoteConfigManager

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
			keychain.patient
		}
		set {
			keychain.patient = newValue
			startUploadOutcomesTimer(timeInterval: remoteConfig.outcomesUploadTimeInterval)
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

	private(set) var carePlan: CHCarePlan?
	private(set) var tasks: [String: CHTask] = [:]

	private(set) lazy var dbStore: CoreDataManager = {
		CoreDataManager(modelName: "HealthStore")
	}()
}

// MARK: - CarePlanResponse

extension CareManager {
	func process(carePlanResponse: CHCarePlanResponse, forceReset: Bool = false, completion: AllieResultCompletion<[CHTask]>?) {
		let queue = DispatchQueue.global(qos: .userInitiated)
		tasks = carePlanResponse.tasks.reduce([:]) { partialResult, task in
			var result = partialResult
			result[task.id] = task
			return result
		}
		carePlan = carePlanResponse.carePlans.active.first
		try? save(carePlanResponse: carePlanResponse)
		var result: OCKStoreError?
		queue.async { [weak self] in
			// There should only be one patient
			let activePatient = carePlanResponse.patients.active.first
			if let patient = activePatient {
				let thePatient = self?.syncProcess(patient: patient, queue: queue)
				ALog.info("patient id \(String(describing: thePatient?.id)), patient uuid = \(String(describing: thePatient?.uuid.uuidString))")
				self?.patient = thePatient
				if thePatient == nil {
					result = OCKStoreError.updateFailed(reason: "Unable to update Patient")
				}
			}

			// There should only be one active CarePlan
			var activeCarePlan: OCKCarePlan?
			let carePlans = carePlanResponse.carePlans
			if result == nil {
				let processedCarePlans = self?.syncProcess(carePlans: carePlans, patient: self?.patient, queue: queue)
				activeCarePlan = processedCarePlans?.active.first
				ALog.info("CarePlan id \(String(describing: activeCarePlan?.id)), carePlan uuid \(String(describing: activeCarePlan?.uuid))")
				if activeCarePlan == nil {
					result = OCKStoreError.updateFailed(reason: "Unable to ")
				}
			}

			let toDelete = carePlanResponse.tasks.deleted
			let toProcess = carePlanResponse.tasks(forCarePlanId: activeCarePlan?.id ?? "")
			if result == nil {
				let processedTasks = self?.syncProcess(tasks: toProcess, carePlan: activeCarePlan, queue: queue) ?? ([], [])
				ALog.info("Regular tasks saved = \(String(describing: processedTasks.0.count)), HealthKitTasks saved \(String(describing: processedTasks.1.count))")
				if (processedTasks.0.count + processedTasks.1.count) != toProcess.count {
					result = OCKStoreError.updateFailed(reason: "Error updating tasks")
				}
			}

			if !carePlanResponse.outcomes.isEmpty, result == nil {
				let outcomes = self?.syncCreateOrUpdate(outcomes: carePlanResponse.outcomes, queue: queue)
				if outcomes == nil {
					result = OCKStoreError.updateFailed(reason: "Outcomes update failed")
				}
				ALog.trace("Number out outcomes saved \(String(describing: outcomes?.count))")
			}
			self?.synchronizeHealthKitOutcomes()

			if let error = result {
				completion?(.failure(error))
			} else {
				completion?(.success(toDelete))
			}
		}
	}

	func register(organization: CHOrganization) -> AnyPublisher<Bool, Never> {
		networkAPI.registerOrganization(organization: organization)
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
