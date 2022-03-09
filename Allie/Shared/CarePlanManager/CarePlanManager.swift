//
//  CarePlanManager.swift
//  Allie
//
//  Created by Waqar Malik on 3/9/22.
//

import CareModel
import CodexFoundation
import Foundation

actor CarePlanManager {
	private let rawCarePlanName = "RawCarePlanResponse.json"
	private let updatedCarePlanName = "UpdatedCarePlanResponse.json"

	private(set) var carePlanResponse: CHCarePlanResponse?
	private(set) var carePlan: CHCarePlan?
	private(set) var tasks: [String: CHTask] = [:]

	init() async {
		let response = try? readCarePlan(name: rawCarePlanName)
		process(carePlanResponse: response)
	}

	func process(carePlanResponse: CHCarePlanResponse?) {
		guard let response = carePlanResponse else {
			return
		}

		carePlan = response.carePlans.active.first
		tasks = response.tasks.reduce([:]) { partialResult, task in
			var result = partialResult
			var modifiedTask = task
			modifiedTask.carePlanId = self.carePlan?.id
			result[task.id] = modifiedTask
			return result
		}
	}

	func save(carePlanResponse: CHCarePlanResponse, forName name: String) throws {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601WithFractionalSeconds
		let data = try encoder.encode(carePlanResponse)
		guard var docmentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
			throw AllieError.missing("Missing")
		}
		docmentsDirectory.appendPathComponent(name)
		try data.write(to: docmentsDirectory, options: .atomicWrite)
	}

	func readCarePlan(name: String) throws -> CHCarePlanResponse {
		guard var docmentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
			throw AllieError.missing("Missing")
		}
		docmentsDirectory.appendPathComponent(name)
		let data = try Data(contentsOf: docmentsDirectory, options: .mappedIfSafe)
		let carePlanResponse = try CHFJSONDecoder().decode(CHCarePlanResponse.self, from: data)
		return carePlanResponse
	}

	func resetCarePlan(name: String) throws {
		let fileManager = FileManager()
		guard var docmentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
			throw AllieError.missing("Missing")
		}
		docmentsDirectory.appendPathComponent(name)
		try fileManager.removeItem(at: docmentsDirectory)
	}
}
