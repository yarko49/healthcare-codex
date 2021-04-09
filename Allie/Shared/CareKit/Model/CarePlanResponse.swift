//
//  CarePlanResponse.swift
//  Allie
//
//  Created by Waqar Malik on 11/29/20.
//

import CareKitStore
import Foundation

public struct CarePlanResponse: Codable {
	public var carePlans: [CarePlan]
	public var patients: [AlliePatient]
	public var tasks: [Task]
	public var outcomes: [Outcome]
	public var vectorClock: [String: Int]

	public init(carePlans: [CarePlan] = [], patients: [AlliePatient] = [], tasks: [Task] = [], outcomes: [Outcome] = [], vectorClock: [String: Int] = [:]) {
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
		carePlans = try container.decodeIfPresent([CarePlan].self, forKey: .carePlans) ?? []
		patients = try container.decodeIfPresent([AlliePatient].self, forKey: .patients) ?? []
		tasks = try container.decodeIfPresent([Task].self, forKey: .tasks) ?? []
		outcomes = try container.decodeIfPresent([Outcome].self, forKey: .outcomes) ?? []
		vectorClock = try container.decodeIfPresent([String: Int].self, forKey: .vectorClock) ?? ["backend": 0]
	}
}
