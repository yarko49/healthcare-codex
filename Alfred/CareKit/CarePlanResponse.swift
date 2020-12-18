//
//  CarePlanResponse.swift
//  alfred-ios
//
//  Created by Waqar Malik on 11/29/20.
//

import CareKitStore
import Foundation

struct CarePlanResponse: Codable {
	let tasks: [String: OCKTask]
	let patients: [String: OCKPatient]
	let carePlans: [String: OCKCarePlan]
	let vectorClock: [String: Int]
}
