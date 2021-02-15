//
//  CarePlanResponse.swift
//  Allie
//
//  Created by Waqar Malik on 11/29/20.
//

import CareKitStore
import Foundation

public struct CarePlanResponse: Codable {
	public let carePlans: CarePlans
	public let tasks: [String: Tasks]
	public let vectorClock: [String: Int]

	public init(carePlans: CarePlans = [:], tasks: [String: Tasks] = [:], vectorClock: [String: Int] = [:]) {
		self.carePlans = carePlans
		self.tasks = tasks
		self.vectorClock = vectorClock
	}

	public var allTasks: [Task] {
		var flatTasks: [Task] = []
		for (_, value) in tasks {
			for (_, innerValue) in value {
				flatTasks.append(innerValue)
			}
		}
		return flatTasks
	}

	public var tasksByKey: [String: Task] {
		var flatTasks: [String: Task] = [:]
		for (_, value) in tasks {
			for (key, innerValue) in value {
				flatTasks[key] = innerValue
			}
		}

		return flatTasks
	}

	private enum CodingKeys: String, CodingKey {
		case carePlans
		case tasks
		case vectorClock
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.carePlans = try container.decode(CarePlans.self, forKey: .carePlans)
		self.tasks = try container.decode([String: Tasks].self, forKey: .tasks)
		self.vectorClock = try container.decode([String: Int].self, forKey: .vectorClock)
	}
}
