//
//  CareManager.swift
//  alfred-ios
//
//  Created by Waqar Malik on 11/23/20.
//

import CareKit
import CareKitStore
import Foundation

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

	@Published var carePlans: [String: Any] = [:]

	@Published var carePlanResponse = CarePlanResponse(patients: [:], carePlans: [:], tasks: [:], clock: [:])

	func getCarePlan() {
		webService.getCarePlan { [self] result in
			switch result {
			case .failure(let error):
				log(.error, "Error fetching care plan data", error: error)
			case .success(let carePlans):
				self.carePlans = carePlans
				log(.info, "Successfully fetch care plan")
			}
		}
	}

	func getCarePlanResponse() {
		webService.getCarePlanResponse { result in
			switch result {
			case .failure(let error):
				log(.error, "Error fetching care plan data", error: error)
			case .success(let carePlanResponse):
				self.carePlanResponse = carePlanResponse
				log(.info, "Successfully fetch care plan")
			}
		}
	}
}

extension CareManager: OCKRemoteSynchronizationDelegate {
	public func didRequestSynchronization(_ remote: OCKRemoteSynchronizable) {}

	public func remote(_ remote: OCKRemoteSynchronizable, didUpdateProgress progress: Double) {}
}
