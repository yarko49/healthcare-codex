//
//  CareManager.swift
//  alfred-ios
//
//  Created by Waqar Malik on 11/23/20.
//

import CareKit
import CareKitStore
import Foundation
import os.log

extension OSLog {
	static let careManager = OSLog(subsystem: subsystem, category: "CareManager")
}

public class CareManager: ObservableObject {
	let remoteSynchronizationManager: RemoteSynchronizationManager
	let store: OCKStore
	let healthKitPassthroughStore: OCKHealthKitPassthroughStore
	let synchronizedStoreManager: OCKSynchronizedStoreManager
	let webService = CareWebService(session: URLSession(configuration: .default))

	init() {
		self.remoteSynchronizationManager = RemoteSynchronizationManager()
		self.store = OCKStore(name: "AlfredStore", type: .inMemory, remote: remoteSynchronizationManager)
		self.healthKitPassthroughStore = OCKHealthKitPassthroughStore(name: "AlfredHealthKitPassthroughStore", type: .inMemory)
		let coordinator = OCKStoreCoordinator()
		coordinator.attach(store: store)
		coordinator.attach(eventStore: healthKitPassthroughStore)
		self.synchronizedStoreManager = OCKSynchronizedStoreManager(wrapping: coordinator)
		remoteSynchronizationManager.delegate = self
	}

	@Published var carePlanResponse = CarePlanResponse(patients: [:], carePlans: [:], tasks: [:], vectorClock: [:])

	func getCarePlanResponse() {
		webService.getCarePlanResponse { result in
			switch result {
			case .failure(let error):
				os_log(.error, log: .careManager, "Error fetching care plan data %@", error.localizedDescription)
			case .success(let response):
				self.carePlanResponse = response
				os_log(.info, log: .careManager, "Successfully fetch care plan")
			}
		}
	}

	func getVectorClock() {
		webService.getCarePlan(vectorClock: true, valueSpaceSample: false) { result in
			switch result {
			case .failure(let error):
				os_log(.error, log: .careManager, "Error fetching care plan vector clock data %@", error.localizedDescription)
			case .success(let response):
				do {
					let data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
					try data.write(to: URL(fileURLWithPath: "/tmp/VectorClockResponse.json"))
				} catch {
					os_log(.error, log: .careManager, "Unable to decode reponse %@", error.localizedDescription)
				}
				os_log(.info, log: .careManager, "Successfully fetch care plan %@", response)
			}
		}
	}

	func getValueSpaceSample() {
		webService.getCarePlan(vectorClock: false, valueSpaceSample: true) { result in
			switch result {
			case .failure(let error):
				os_log(.error, log: .careManager, "Error fetching care plan vector clock data %@", error.localizedDescription)
			case .success(let response):
				do {
					let data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
					try data.write(to: URL(fileURLWithPath: "/tmp/ValueSpaceResponse.json"))
				} catch {
					os_log(.error, log: .careManager, "Unable to decode reponse %@", error.localizedDescription)
				}
				os_log(.info, log: .careManager, "Successfully fetch care plan %@", response)
			}
		}
	}
}

extension CareManager: OCKRemoteSynchronizationDelegate {
	public func didRequestSynchronization(_ remote: OCKRemoteSynchronizable) {}

	public func remote(_ remote: OCKRemoteSynchronizable, didUpdateProgress progress: Double) {}
}
