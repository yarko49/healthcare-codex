//
//  CarePlanResponse.swift
//  alfred-ios
//
//  Created by Waqar Malik on 11/29/20.
//

import CareKitStore
import Foundation

public struct CarePlanResponse: Codable {
	public let patients: [String: OCKPatient]
	public let carePlans: [String: OCKCarePlan]
	public let tasks: [String: OCKTask]
	public let clock: [String: Int]
}
