//
//  CarePlanResponse.swift
//  Allie
//
//  Created by Waqar Malik on 11/29/20.
//

import CareKitStore
import Foundation

public struct CarePlanResponse: Codable {
	public var carePlans: [CarePlan]?
	public var patients: [AlliePatient]?
	public var tasks: [Task]?
	public var outcomes: [Outcome]?
	public var vectorClock: [String: Int]

	public init(carePlans: [CarePlan]? = nil, patients: [AlliePatient]? = nil, tasks: [Task]? = nil, outcomes: [Outcome]? = nil, vectorClock: [String: Int] = [:]) {
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
		case vectorClock
	}
}
