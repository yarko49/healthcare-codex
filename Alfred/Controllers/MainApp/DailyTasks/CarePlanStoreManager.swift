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
import WatchConnectivity

class CarePlanStoreManager: ObservableObject {
	typealias BoolCompletion = (Bool) -> Void

	enum Constants {
		static let careKitTasksStore = "TasksStore"
		static let healthKitPassthroughStore = "HealthKitPassthroughStore"
		static let coreDataStoreType: OCKCoreDataStoreType = .inMemory
		static let dummyPatientIdentifier: String = "dummy-patient"
	}

	private(set) lazy var remoteSynchronizationManager: RemoteSynchronizationManager = {
		let manager = RemoteSynchronizationManager()
		manager.delegate = self
		return manager
	}()

	private(set) lazy var watchConnectivityPeer = OCKWatchConnectivityPeer()
	private(set) lazy var healthKitPassthroughStore = OCKHealthKitPassthroughStore(name: Constants.healthKitPassthroughStore, type: Constants.coreDataStoreType)
	private(set) lazy var store = OCKStore(name: Constants.careKitTasksStore, type: Constants.coreDataStoreType, remote: remoteSynchronizationManager)
	private(set) lazy var synchronizedStoreManager: OCKSynchronizedStoreManager = {
		let coordinator = OCKStoreCoordinator()
		coordinator.attach(store: store)
		coordinator.attach(eventStore: healthKitPassthroughStore)
		let manager = OCKSynchronizedStoreManager(wrapping: coordinator)
		return manager
	}()

	@Published private(set) var patient: OCKPatient = {
		OCKPatient(id: Constants.dummyPatientIdentifier, givenName: "", familyName: "")
	}()

	@Published private(set) var carePlan: OCKCarePlan = {
		OCKCarePlan(id: "dummy-careplan", title: "Dummy CarePlan", patientUUID: nil)
	}()

	private var fetchQueue: DispatchQueue = {
		let processName = ProcessInfo.processInfo.processName
		let queueLabel = Bundle.main.bundleIdentifier! + "." + processName
		let queue = DispatchQueue(label: queueLabel, qos: .utility, attributes: [], autoreleaseFrequency: .inherit, target: nil)
		return queue
	}()

	func populateStore(completion: BoolCompletion?) {
		let dispatchGroup = DispatchGroup()
		var bundle: CodexBundle?
		var careResponse: CarePlanResponse?
		dispatchGroup.enter()
		AlfredClient.client.postPatientSearch { result in
			switch result {
			case .success(let response):
				bundle = response
			case .failure(let error):
				ALog.error("Patient Search \(error.localizedDescription)")
			}
			dispatchGroup.leave()
		}

		dispatchGroup.enter()
		AlfredClient.client.getCarePlan { result in
			switch result {
			case .failure(let error):
				ALog.error("Fetching CarePlan \(error.localizedDescription)")
			case .success(let carePlanResponse):
				careResponse = carePlanResponse
			}
			dispatchGroup.leave()
		}

		dispatchGroup.notify(qos: .background, flags: .barrier, queue: DispatchQueue.global(qos: .background)) { [weak self] in
			if let resource = bundle?.entry?.first?.resource, let patient = OCKPatient(resource: resource, user: Auth.auth().currentUser) {
				self?.process(patient: patient)
				self?.patient = patient
			}
			if let response = careResponse {
				self?.process(carePlans: response.carePlans)
				self?.process(tasks: response.allTasks)
			}

			completion?(bundle != nil && careResponse != nil)
		}
	}
}

// MARK: - CarePlan

extension CarePlanStoreManager {
	func process(carePlans plans: CarePlans) {
		let carePlans = plans.values.map { (carePlan) -> OCKCarePlan in
			var plan = OCKCarePlan(carePlan: carePlan)
			plan.patientUUID = self.patient.uuid
			return plan
		}
		store.addCarePlans(carePlans)
		if let first = carePlans.first {
			carePlan = first
		}
	}

	func fetchCarePlanFromServer(forPatient patient: OCKPatient, completion: BoolCompletion?) {
		AlfredClient.client.getCarePlan { [weak self] result in
			switch result {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
				completion?(false)
			case .success(let carePlanResponse):
				let carePlans = carePlanResponse.carePlans.values.map { (carePlan) -> OCKCarePlan in
					var plan = OCKCarePlan(carePlan: carePlan)
					plan.patientUUID = patient.uuid
					return plan
				}
				self?.store.addCarePlans(carePlans)
				if let first = carePlans.first {
					self?.carePlan = first
				}
				completion?(true)
			}
		}
	}
}

// MARK: - Tasks

extension CarePlanStoreManager {
	func process(tasks: [Task]) {
		let ockTasks = tasks.map { (task) -> OCKTask in
			OCKTask(task: task)
		}

		for task in ockTasks {
			store.addTask(task)
		}
	}
}

// MARK: - Patients

extension CarePlanStoreManager {
	func process(patient: OCKPatient) {
		let query = OCKPatientQuery(id: patient.id)
		store.fetchPatients(query: query, callbackQueue: fetchQueue) { [weak self] result in
			switch result {
			case .failure(let error):
				ALog.trace("processPatient error \(error.errorDescription ?? error.localizedDescription)")
				self?.store.addPatient(patient)
			case .success(let patients):
				let existing = patients.filter { (item) -> Bool in
					item.id == patient.id
				}
				if let existingPatient = existing.first {
					self?.store.deletePatients([existingPatient])
				}
				self?.store.addPatient(patient)
			}
		}
	}

	func fetchPatient(completion: BoolCompletion?) {
		guard let identifier = DataContext.shared.userModel?.userID else {
			completion?(false)
			return
		}
		let query = OCKPatientQuery(id: identifier)
		store.fetchPatients(query: query, callbackQueue: fetchQueue) { [weak self] result in
			switch result {
			case .failure(let error):
				ALog.error("\(error.errorDescription ?? error.localizedDescription)")
				completion?(false)
			case .success(let patients):
				guard let existingPatient = patients.first else {
					self?.createPatientFromServer(completion: completion)
					return
				}
				self?.patient = existingPatient
				completion?(true)
			}
		}
	}

	func createPatientFromServer(completion: BoolCompletion?) {
		AlfredClient.client.postPatientSearch { [weak self] result in
			switch result {
			case .success(let response):
				guard let resource = response.entry?.first?.resource else {
					completion?(false)
					return
				}
				if let newPatient = OCKPatient(resource: resource, user: Auth.auth().currentUser) {
					self?.store.addPatients([newPatient])
					self?.patient = newPatient
					completion?(true)
					return
				}
				completion?(false)
			case .failure(let error):
				ALog.error("Patient Search \(error.localizedDescription)")
				completion?(false)
			}
		}
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

// MARK: - WatchSessionManager

private class WatchSessionManager: NSObject, WCSessionDelegate {
	fileprivate var watchConnecivityPeer: OCKWatchConnectivityPeer!
	fileprivate var store: OCKStore!

	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		if let error = error {
			ALog.error("WCSession activation did complete: \(activationState), error: \(error.localizedDescription)")
		} else {
			ALog.info("WCSession activation did complete: \(activationState)")
		}
	}

	func sessionDidBecomeInactive(_ session: WCSession) {
		ALog.info("WCSession did become inactive")
	}

	func sessionDidDeactivate(_ session: WCSession) {
		ALog.info("WCSession did deactivate")
	}

	func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
		ALog.info("WCSession did recived message \(message)")
		watchConnecivityPeer.reply(to: message, store: store) { reply in
			replyHandler(reply)
		}
	}
}
