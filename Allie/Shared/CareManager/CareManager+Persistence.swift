//
//  CareManager+Persistence.swift
//  Allie
//
//  Created by Waqar Malik on 3/11/22.
//

import CareModel
import CodexFoundation
import Foundation

extension CareManager {
	var rawCarePlanName: String { "CarePlanResponse.json" }
	var updatedCarePlanName: String { "UpdatedCarePlanResponse.json" }

	func process(carePlanResponse: CHCarePlanResponse?) {
		guard let response = carePlanResponse else {
			return
		}

		self.carePlanResponse = response
		if let activePatient = response.patients.active.first, activePatient != patient {
			patient = activePatient
		}
		activeCarePlan = response.carePlans.active.first
		let activeCarePlanId = activeCarePlan?.id ?? "unknown"
		tasks.removeAll()
		response.tasks.forEach { task in
			if let carePlanId = task.carePlanId, carePlanId == activeCarePlanId {
				tasks[task.id] = task
			}
		}

		carePlans.removeAll()
		carePlans = response.carePlans.reduce([:]) { partialResult, carePlan in
			var result = partialResult
			result[carePlan.id] = carePlan
			return result
		}
	}

	func save(carePlanResponse: CHCarePlanResponse, forName name: String) throws {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601WithFractionalSeconds
		let data = try encoder.encode(carePlanResponse)
		guard var docmentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
			throw AllieError.missing("Missing CarePlan \(name)")
		}
		docmentsDirectory.appendPathComponent(name)
		try data.write(to: docmentsDirectory, options: .atomicWrite)
	}

	func loadCarePlan(name: String) throws -> CHCarePlanResponse {
		guard var docmentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
			throw AllieError.missing("Missing CarePlan \(name)")
		}
		docmentsDirectory.appendPathComponent(name)
		let data = try Data(contentsOf: docmentsDirectory, options: .mappedIfSafe)
		let carePlanResponse = try CHFJSONDecoder().decode(CHCarePlanResponse.self, from: data)
		return carePlanResponse
	}

	func removeCarePlan(name: String) throws {
		let fileManager = FileManager()
		guard var docmentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
			throw AllieError.missing("Missing CarePlan \(name)")
		}
		docmentsDirectory.appendPathComponent(name)
		if fileManager.fileExists(atPath: docmentsDirectory.path) {
			try fileManager.removeItem(at: docmentsDirectory)
		}
	}

	func saveCarePlan() throws {
		guard let carePlanResponse = carePlanResponse else {
			throw AllieError.missing("CarePlan Does not exists")
		}
		try save(carePlanResponse: carePlanResponse, forName: rawCarePlanName)
	}

	func loadCarePlan() throws {
		let response = try loadCarePlan(name: rawCarePlanName)
		process(carePlanResponse: response)
	}

	func resetCarePlan() throws {
		carePlanResponse = nil
		activeCarePlan = nil
		tasks.removeAll(keepingCapacity: true)
		carePlans.removeAll(keepingCapacity: true)
		try removeCarePlan(name: rawCarePlanName)
		try removeCarePlan(name: updatedCarePlanName)
	}
}
