//
//  CareManager+CarePlan.swift
//  Allie
//
//  Created by Waqar Malik on 9/11/21.
//

import CareKitStore
import Foundation

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
						ALog.error("\(error.localizedDescription)", metadata: ["CareManager": "Add Care Plan"])
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
						ALog.error("\(error.localizedDescription)", metadata: ["CareManager": "Update Care Plan"])
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

	func process(carePlan: CHCarePlan, patient: CHPatient?) async throws -> CHCarePlan {
		var updatedCarePlan = carePlan
		var ockCarePlan = OCKCarePlan(carePlan: carePlan)
		ockCarePlan.patientUUID = patient?.uuid
		do {
			let existingCarePlan = try await store.fetchCarePlan(withID: ockCarePlan.id)
			let merged = existingCarePlan.merged(newCarePlan: ockCarePlan)
			let newCarePlan = try await store.updateCarePlan(merged)
			updatedCarePlan.uuid = newCarePlan.uuid
		} catch {
			let newCarePlan = try await store.addCarePlan(ockCarePlan)
			updatedCarePlan.uuid = newCarePlan.uuid
		}

		return updatedCarePlan
	}

	func process(carePlans: [CHCarePlan], patient: CHPatient?) async throws -> [CHCarePlan] {
		var updatedCarePlans: [CHCarePlan] = []
		for carePlan in carePlans {
			do {
				let updated = try await process(carePlan: carePlan, patient: patient)
				updatedCarePlans.append(updated)
			} catch {
				ALog.error("Unable to update the careplan \n")
			}
		}
		return updatedCarePlans
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
					ALog.error("\(error.localizedDescription)", metadata: ["CareManager": "Process Care Plan"])
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
