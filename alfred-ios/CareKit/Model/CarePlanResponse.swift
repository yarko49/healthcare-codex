//
//  CarePlanResponse.swift
//  alfred-ios
//
//  Created by Waqar Malik on 11/29/20.
//

import CareKitStore
import Foundation

public struct CarePlanResponse: Codable {
	public let patients: Patients
	public let carePlans: CarePlans
	public let tasks: [String: Tasks]
	public let vectorClock: [String: Int]
}
