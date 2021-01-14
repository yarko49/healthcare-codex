//
//  CarePlanResponse.swift
//  Alfred
//
//  Created by Waqar Malik on 11/29/20.
//

import CareKitStore
import Foundation

public struct CarePlanResponse: Codable, Hashable {
	public let patients: Patients?
	public let carePlans: CarePlans
	public let tasks: [String: Tasks]
	public let vectorClock: [String: Int]

	public init(patients: Patients = [:], carePlans: CarePlans = [:], tasks: [String: Tasks] = [:], vectorClock: [String: Int] = [:]) {
		self.patients = patients
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
}
