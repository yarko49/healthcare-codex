//
//  CareManager+CarePlan.swift
//  Allie
//
//  Created by Waqar Malik on 9/11/21.
//

import CareKitStore
import CareModel
import Foundation

extension CareManager {
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

	func deleteAllCarePlans() async throws {
		let dateInterval = DateInterval(start: Date.distantPast, end: Date.distantFuture)
		let carePlanQuery = OCKCarePlanQuery(dateInterval: dateInterval)
		let allCarePlans = try await store.fetchAnyCarePlans(query: carePlanQuery)
		if !allCarePlans.isEmpty {
			_ = try await store.deleteAnyCarePlans(allCarePlans)
		}
	}

	func deleteCarePlans(exclude: [String]) async throws {
		let dateInterval = DateInterval(start: Date.distantPast, end: Date.distantFuture)
		let carePlanQuery = OCKCarePlanQuery(dateInterval: dateInterval)
		let allCarePlans = try await store.fetchAnyCarePlans(query: carePlanQuery)
		let filtered = allCarePlans.filter { carePlan in
			!exclude.contains(carePlan.id)
		}

		guard !filtered.isEmpty else {
			return
		}
		_ = try await store.deleteAnyCarePlans(filtered)
	}
}
