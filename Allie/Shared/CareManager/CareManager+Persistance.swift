//
//  CareManager+Persistance.swift
//  Allie
//
//  Created by Waqar Malik on 10/15/21.
//

import Foundation
extension CareManager {
	func save(carePlanResponse: CHCarePlanResponse) throws {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601WithFractionalSeconds
		let data = try encoder.encode(carePlanResponse)
		guard var docmentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
			throw AllieError.missing("Missing")
		}
		docmentsDirectory.appendPathComponent("CarePlanResponse.json")
		try data.write(to: docmentsDirectory, options: .atomicWrite)
	}

	func readCarePlan() throws -> CHCarePlanResponse {
		guard var docmentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first else {
			throw AllieError.missing("Missing")
		}
		docmentsDirectory.appendPathComponent("CarePlanResponse.json")
		let data = try Data(contentsOf: docmentsDirectory, options: .mappedIfSafe)
		let carePlanResponse = try CHJSONDecoder().decode(CHCarePlanResponse.self, from: data)
		return carePlanResponse
	}

	func resetCarePlan() throws {
		let fileManager = FileManager()
		guard var docmentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
			throw AllieError.missing("Missing")
		}
		docmentsDirectory.appendPathComponent("CarePlanResponse.json")
		try fileManager.removeItem(at: docmentsDirectory)
	}
}
