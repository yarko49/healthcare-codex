//
//  CarePlanResponse.swift
//  Allie
//
//  Created by Waqar Malik on 11/29/20.
//

import CareKitStore
import Foundation

struct CHCarePlanResponse: Codable {
	var carePlans: [CHCarePlan]
	var patients: [CHPatient]
	var tasks: [CHTask]
	var faultyTasks: [CHBasicTask]?
	var outcomes: [CHOutcome]
	var vectorClock: UInt64

	init(carePlans: [CHCarePlan] = [], patients: [CHPatient] = [], tasks: [CHTask] = [], outcomes: [CHOutcome] = [], vectorClock: UInt64 = 0) {
		self.carePlans = carePlans
		self.tasks = tasks
		self.vectorClock = vectorClock
		self.patients = patients
		self.outcomes = outcomes
	}

	private enum CodingKeys: String, CodingKey {
		case carePlans
		case patients
		case tasks
		case outcomes
		case vectorClock
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.carePlans = try container.decodeIfPresent([CHCarePlan].self, forKey: .carePlans) ?? []
		self.patients = try container.decodeIfPresent([CHPatient].self, forKey: .patients) ?? []
		self.patients = patients.filter { patient in
			!patient.id.isEmpty
		}
		let (validTasks, faultyTasks) = container.safelyDecodeArray(of: CHTask.self, alternate: CHBasicTask.self, forKey: .tasks)
		self.tasks = validTasks
		if !faultyTasks.isEmpty {
			self.faultyTasks = faultyTasks
		}
		self.tasks = tasks.filter { task in
			if task.groupIdentifier == "LINK", task.links == nil {
				return false
			}
			return true
		}
		self.outcomes = try container.decodeIfPresent([CHOutcome].self, forKey: .outcomes) ?? []
		self.vectorClock = try container.decodeIfPresent(UInt64.self, forKey: .vectorClock) ?? 0
	}
}

extension CHCarePlanResponse {
	func tasks(forCarePlanId carePlanId: String) -> CHTasks {
		let filtered = tasks.filter { task in
			guard let planId = task.carePlanId else {
				return false
			}
			return carePlanId == planId
		}
		return filtered
	}
}
