//
//  CareManager.swift
//  alfred-ios
//
//  Created by Waqar Malik on 11/23/20.
//

import CareKit
import CareKitStore
import Foundation

class CareManager: ObservableObject {
	let remoteSynchronizationManager: RemoteSynchronizationManager
	let store: OCKStore
	let healthKitPassthroughStore: OCKHealthKitPassthroughStore
	let synchronizedStoreManager: OCKSynchronizedStoreManager

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
}

extension CareManager: OCKRemoteSynchronizationDelegate {
	func didRequestSynchronization(_ remote: OCKRemoteSynchronizable) {}

	func remote(_ remote: OCKRemoteSynchronizable, didUpdateProgress progress: Double) {}
}
