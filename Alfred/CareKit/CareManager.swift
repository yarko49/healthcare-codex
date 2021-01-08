//
//  CareManager.swift
//  Alfred
//
//  Created by Waqar Malik on 11/23/20.
//

import CareKit
import CareKitStore
import Combine
import Foundation

public class CareManager: ObservableObject {
	let remoteSynchronizationManager: RemoteSynchronizationManager
	public let store: OCKStore
	public let healthKitPassthroughStore: OCKHealthKitPassthroughStore
	public let synchronizedStoreManager: OCKSynchronizedStoreManager

	public init(careKitStore ckStore: String = "AlfredStore", healthKitStore hkStore: String = "AlfredHealthKitPassthroughStore") {
		self.remoteSynchronizationManager = RemoteSynchronizationManager()
		self.store = OCKStore(name: ckStore, type: .inMemory, remote: remoteSynchronizationManager)
		self.healthKitPassthroughStore = OCKHealthKitPassthroughStore(name: hkStore, type: .inMemory)
		let coordinator = OCKStoreCoordinator()
		coordinator.attach(store: store)
		coordinator.attach(eventStore: healthKitPassthroughStore)
		self.synchronizedStoreManager = OCKSynchronizedStoreManager(wrapping: coordinator)
		remoteSynchronizationManager.delegate = self
	}

	public func getCarePlanResponse() {
		AlfredClient.client.getCarePlan { result in
			switch result {
			case .failure(let error):
				ALog.error("Error fetching care plan data \(error.localizedDescription)")
			case .success(let response):
				ALog.info("Successfully fetch care plan \(String(describing: response))")
			}
		}
	}

	public func getRawCarePlan() {
		let route = APIRouter.getCarePlan(vectorClock: false, valueSpaceSample: false)
		AlfredClient.client.getRawReaults(route: route) { result in
			switch result {
			case .failure(let error):
				ALog.error("Error fetching raw care plan data \(error.localizedDescription)")
			case .success(let carePlan):
				do {
					let data = try JSONSerialization.data(withJSONObject: carePlan, options: .prettyPrinted)
					var documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
					documentsFolder = documentsFolder.appendingPathComponent("carePlan.json")
					try data.write(to: documentsFolder)
				} catch {
					ALog.error("Error writing data \(error.localizedDescription)")
				}
			}
		}
	}

	public func getVectorClock() {
		AlfredClient.client.getCarePlan(vectorClock: true, valueSpaceSample: false) { result in
			switch result {
			case .failure(let error):
				ALog.error("Error fetching care plan vector clock data \(error.localizedDescription)")
			case .success(let response):
				do {
					let data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
					try data.write(to: URL(fileURLWithPath: "/tmp/VectorClockResponse.json"))
				} catch {
					ALog.error("Unable to decode reponse \(error.localizedDescription)")
				}
				ALog.info("Successfully fetch care plan \(String(describing: response))")
			}
		}
	}

	public func getValueSpaceSample() {
		AlfredClient.client.getCarePlan(vectorClock: false, valueSpaceSample: true) { result in
			switch result {
			case .failure(let error):
				ALog.error("Error fetching care plan vector clock data \(error.localizedDescription)")
			case .success(let response):
				do {
					let data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
					try data.write(to: URL(fileURLWithPath: "/tmp/ValueSpaceResponse.json"))
				} catch {
					ALog.error("Unable to decode reponse \(error.localizedDescription)")
				}
				ALog.info("Successfully fetch care plan \(String(describing: response))")
			}
		}
	}
}

extension CareManager: OCKRemoteSynchronizationDelegate {
	public func didRequestSynchronization(_ remote: OCKRemoteSynchronizable) {
		ALog.info("")
	}

	public func remote(_ remote: OCKRemoteSynchronizable, didUpdateProgress progress: Double) {
		ALog.info("")
	}
}
