//
//  CarePlanResponse.swift
//  Allie
//
//  Created by Waqar Malik on 11/29/20.
//

import CareKitStore
import Foundation

public struct CarePlanResponse: Codable {
	public let carePlans: [String: CarePlan]
	public let patients: [String: AlliePatient]?
	public let tasks: [String: Task]
	public let vectorClock: [String: Int]

	public init(carePlans: [String: CarePlan] = [:], patients: [String: AlliePatient] = [:], tasks: [String: Task] = [:], vectorClock: [String: Int] = [:]) {
		self.carePlans = carePlans
		self.tasks = tasks
		self.vectorClock = vectorClock
		self.patients = patients
	}

	public var allCarePlans: [CarePlan] {
		carePlans.map { (item) -> CarePlan in
			var newPlan = item.value
			if newPlan.id == "" {
				newPlan.id = item.key
			}
			return newPlan
		}
	}

	public var allTasks: [Task] {
		Array(tasks.values)
	}

	public var allPatients: [AlliePatient] {
		guard let values = patients?.values else {
			return []
		}
		return Array(values)
	}

	private enum CodingKeys: String, CodingKey {
		case carePlans
		case patients
		case tasks
		case vectorClock
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.carePlans = try container.decode([String: CarePlan].self, forKey: .carePlans)
		let tasks = try container.decode([String: [String: Task]].self, forKey: .tasks)
		var flatTasks: [String: Task] = [:]
		for (_, value) in tasks {
			for (key, innerValue) in value {
				flatTasks[key] = innerValue
			}
		}
		self.patients = try container.decodeIfPresent([String: AlliePatient].self, forKey: .patients) ?? [:]
		self.tasks = flatTasks
		self.vectorClock = try container.decode([String: Int].self, forKey: .vectorClock)
	}
}
