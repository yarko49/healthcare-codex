//
//  CHTask+CGM.swift
//  Allie
//
//  Created by Waqar Malik on 1/26/22.
//

import CareKitStore
import Foundation
import HealthKit

extension CHTask {
	static func createCGMTask(forCarePlan carePlanId: String) -> CHTask {
		let startDate = Calendar.current.startOfDay(for: Date())
		let schedule = OCKSchedule.dailyAtTime(hour: 0, minutes: 0, start: startDate, end: nil, text: nil)
		var task = CHTask(id: "measurements-cgm", title: "Bluetooth CGM", carePlanUUID: nil, schedule: schedule)
		task.carePlanId = carePlanId
		task.isHidden = true
		task.groupIdentifier = "BLUETOOTH_CGM"
		task.createdDate = startDate
		task.deletedDate = Date.distantFuture
		task.effectiveDate = startDate
		task.instructions = "Monitor daily glucose levels"
		task.impactsAdherence = false
		task.userInfo = ["category": "measurements", "priority": "0"]
		let linkage = OCKHealthKitLinkage(quantityIdentifier: .bloodGlucose, quantityType: .discrete, unit: HKUnit(from: "mg/dl"))
		task.healthKitLinkage = linkage

		return task
	}
}
