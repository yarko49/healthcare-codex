//
//  CarePlanResponse.swift
//  Allie
//
//  Created by Waqar Malik on 11/29/20.
//

import CareKitStore
import Foundation

public struct CarePlanResponse: Codable {
	public let carePlans: [CarePlan]
	public let tasks: [String: Task]
	public let vectorClock: [String: Int]

	public init(carePlans: [CarePlan] = [], tasks: [String: Task] = [:], vectorClock: [String: Int] = [:]) {
		self.carePlans = carePlans
		self.tasks = tasks
		self.vectorClock = vectorClock
	}

	public var allTasks: [Task] {
		Array(tasks.values)
	}

	private enum CodingKeys: String, CodingKey {
		case carePlans
		case tasks
		case vectorClock
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let plans = try container.decode([String: CarePlan].self, forKey: .carePlans)
		self.carePlans = plans.map { (item) -> CarePlan in
			var newPlan = item.value
			if newPlan.id == "" {
				newPlan.id = item.key
			}
			return newPlan
		}
		let tasks = try container.decode([String: [String: Task]].self, forKey: .tasks)
		var flatTasks: [String: Task] = [:]
		for (_, value) in tasks {
			for (key, innerValue) in value {
				flatTasks[key] = innerValue
			}
		}
		self.tasks = flatTasks
		self.vectorClock = try container.decode([String: Int].self, forKey: .vectorClock)
	}
}
