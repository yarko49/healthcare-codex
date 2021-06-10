//
//  CarePlanResponse.swift
//  Allie
//
//  Created by Waqar Malik on 11/29/20.
//

import CareKitStore
import Foundation

public struct CHCarePlanResponse: Codable {
	public var carePlans: [CHCarePlan]
	public var patients: [CHPatient]
	public var tasks: [CHTask]
	public var faultyTasks: [CHBasicTask]?
	public var outcomes: [CHOutcome]
	public var vectorClock: UInt64

	public init(carePlans: [CHCarePlan] = [], patients: [CHPatient] = [], tasks: [CHTask] = [], outcomes: [CHOutcome] = [], vectorClock: UInt64 = 0) {
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

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		carePlans = try container.decodeIfPresent([CHCarePlan].self, forKey: .carePlans) ?? []
		patients = try container.decodeIfPresent([CHPatient].self, forKey: .patients) ?? []
		let decodedTasks = container.safelyDecodeArray(of: CHTask.self, alternate: CHBasicTask.self, forKey: .tasks)
		tasks = decodedTasks.0
		if !decodedTasks.1.isEmpty {
			self.faultyTasks = decodedTasks.1
		}
		self.outcomes = try container.decodeIfPresent([CHOutcome].self, forKey: .outcomes) ?? []
		self.vectorClock = try container.decodeIfPresent(UInt64.self, forKey: .vectorClock) ?? 0
	}
}
